#!/usr/bin/perl
use strict;
use warnings;
use v5.20;

use autodie qw(:all);
use Cwd;

# packages and dependencies are given in @ARGV as Makefile targets,
# e.g. "package-yaourt" for the package "yaourt", so strip these "package-"
# prefixes
my ($package, @deps) = map { /^package-(.+)$/ ? $1 : () } @ARGV;

################################################################################
# install missing dependencies

sub version_of_aurpackage {
   my ($package) = @_;

   # read the .SRCINFO file of the $package
   open my $fh, '<', "../$package/.SRCINFO";
   my ($pkgver, $pkgrel);
   while (<$fh>) {
      if (/^\s*pkgver\s*=\s*(.+)$/) {
         $pkgver = $1;
      }
      elsif (/^\s*pkgrel\s*=\s*(.+)$/) {
         $pkgrel = $1;
      }
   }
   close $fh;

   # construct the version string
   return "$pkgver-$pkgrel";
}

sub file_for_aurpackage {
   my ($pkg, $ver, $dont_die) = @_;
   my ($package_file) = glob("../repo/$pkg-$ver-*.pkg.tar.xz");
   die "cannot find ../repo/$pkg-$ver-*.pkg.tar.xz"
      unless $dont_die or $package_file;
   return $package_file;
}

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
# build package if it's not yet there

my $package_version = version_of_aurpackage($package);
my $package_file = file_for_aurpackage($package, $package_version, '-nodie');

unless ($package_file) {
   local $ENV{PKGDEST} = getcwd() . '/../repo';
   system(qw(makepkg -s));
}
