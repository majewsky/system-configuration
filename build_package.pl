#!/usr/bin/perl
use strict;
use warnings;
use v5.20;

use autodie qw(:all);
use Cwd;

# the first argument is the package name
my $package = shift @ARGV;
# dependencies are given in @ARGV as Makefile targets, e.g. "package-yaourt"
# for the package "yaourt", so strip these "package-" prefixes
my @deps = map { /^package-(.+)$/ ? $1 : () } grep { !/\.SRCINFO/ } @ARGV;

################################################################################
# build package if it's not yet there

sub version_of_aurpackage {
   my ($package) = @_;
   my ($epoch, $pkgver, $pkgrel);

   # read the .SRCINFO of the $package
   open my $fh, '<', "../$package/.SRCINFO";
   while (<$fh>) {
      if (/^\s*pkgver = (.+?)$/) {
         $pkgver = $1;
      }
      elsif (/^\s*pkgrel = (.+?)$/) {
         $pkgrel = $1;
      }
      elsif (/^\s*epoch = (.+?)$/) {
         $epoch = $1;
      }
   }
   close $fh;

   die "cannot find pkgver for package $package" unless $pkgver;
   die "cannot find pkgrel for package $package" unless $pkgrel;

   # construct the version string
   return $epoch ? "$epoch:$pkgver-$pkgrel" : "$pkgver-$pkgrel";
}

sub file_for_aurpackage {
   my ($pkg, $ver, $dont_die) = @_;
   my ($package_file) = glob("../repo/$pkg-$ver-*.pkg.tar.xz");
   die "cannot find ../repo/$pkg-$ver-*.pkg.tar.xz"
      unless $dont_die or $package_file;
   return $package_file;
}

my $package_version = version_of_aurpackage($package);
exit if file_for_aurpackage($package, $package_version, '-nodie');

################################################################################
# install missing dependencies

# which dependencies are not yet satisfied?
my @deps_with_versions = map { "$_=" . version_of_aurpackage($_) } map{$_} @deps;
my @missing_deps = do { open my $fh, '-|', qw(pacman -T), @deps_with_versions; <$fh> };
chomp for @missing_deps;

# the Makefile ensures that our deps have already been built, so we can
# readily install them from their
my @dep_package_files;
for my $dep_with_version (@missing_deps) {
   # $dep_with_version = 'foo-bar=1.2-1'
   my ($dep_pkg, $dep_ver) = split /=/, $dep_with_version;
   # ($dep_pkg, $dep_ver) = ('foo-bar', '1.2-1')
   my $dep_package_file = file_for_aurpackage($dep_pkg, $dep_ver);
   say "Installing $dep_package_file to satisfy dependency for $package...";
   push @dep_package_files, $dep_package_file;
}

system(qw(sudo pacman -U --asdeps), @dep_package_files) if @dep_package_files;

################################################################################
# build package

# write the resulting package to the repo directory
local $ENV{PKGDEST} = getcwd() . '/../repo';
system qw(makepkg -s);

# add it to the repo metadata
system qw(repo-add -n ../repo/holograms.db.tar.xz), file_for_aurpackage($package, $package_version);
