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
my @deps = map { /^package-(.+)$/ ? $1 : () } @ARGV;

################################################################################
# install missing dependencies

sub version_of_aurpackage {
   my ($package) = @_;
   my ($epoch, $pkgver, $pkgrel);

   # read the .SRCINFO (for AUR packages) or the PKGBUILD (for holograms) of the $package
   my $filename = (-f "../$package/.SRCINFO") ? "../$package/.SRCINFO" : "../$package/PKGBUILD";
   open my $fh, '<', $filename;
   while (<$fh>) {
      if (/^\s*pkgver\s*=\s*['"]?(.+?)['"]?\s*$/) {
         $pkgver = $1;
      }
      elsif (/^\s*pkgrel\s*=\s*['"]?(.+?)['"]?\s*$/) {
         $pkgrel = $1;
      }
      elsif (/^\s*epoch\s*=\s*['"]?(.+?)['"]?\s*$/) {
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
   # write the resulting package to the repo directory

   local $ENV{PKGDEST} = getcwd() . '/../repo';

   # skip integrity checks (md5sums etc.) for holograms
   my @command = qw(makepkg -s);
   if ($package =~ /^holo(?:gram|deck)/) {
      push @command, '--skipchecksums';
   }
   system @command;
}

$package_file = file_for_aurpackage($package, $package_version, '-nodie');

################################################################################
# clean earlier versions of this package

for my $other_file (glob("../repo/$package-*.pkg.tar.xz")) {
   # check that this is not the latest version of the package
   next if $other_file eq $package_file;
   # check that this is really a file for this package, not for another package
   # whose name starts with that of the current package (globs can't tell that
   # apart)
   next if $other_file !~ m{^\.\./repo/\Q$package\E-[0-9.a-z_]+-[0-9]+-.*\.pkg\.tar\.xz};
   say "Cleaning up $other_file (looks like an old version of $package-$package_version)";
   unlink $other_file;
}

