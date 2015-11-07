#!/usr/bin/perl
use strict;
use warnings;
use v5.20;

use autodie qw(:all);
use IPC::Open2;

# the first argument is the package definition file
my $filename = shift @ARGV;

# read file for package name, version (TODO: recognize epoch)
my ($pkgname, $pkgver, $pkgrel) = (undef, undef, 1);
open my $fh, '<', $filename;
while (<$fh>) {
   if (/^\s*name\s*=\s*"(.+?)"\s*$/) {
      $pkgname = $1;
   }
   elsif (/^\s*version\s*=\s*"(.+?)"\s*$/) {
      $pkgver = $1;
   }
   elsif (/^\s*release\s*=\s*(\d+?)\s*$/) {
      $pkgrel = $1;
   }
   elsif (/^\[(?!package)/) {
      last;
   }
}
close($fh);

################################################################################
# build package if it's not yet there
#
# (we're running inside the repo directory, so auto-output is fine)

my $package_file = "$pkgname-$pkgver-$pkgrel-any.pkg.tar.xz";
system("holo-build <$filename") unless -f $package_file;

################################################################################
# clean earlier versions of this package

for my $other_file (glob("$pkgname-*.pkg.tar.xz")) {
   # check that this is not the latest version of the package
   next if $other_file eq $package_file;
   # check that this is really a file for this package, not for another package
   # whose name starts with that of the current package (globs can't tell that
   # apart)
   next if $other_file !~ m{^\Q$pkgname\E-[0-9.]+-[0-9]+-.*\.pkg\.tar\.xz};
   say "Cleaning up $other_file (looks like an old version of $pkgname-$pkgver-$pkgrel)";
   unlink $other_file;
}

