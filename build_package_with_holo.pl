#!/usr/bin/perl
use strict;
use warnings;
use v5.20;

use autodie qw(:all);
use IPC::Open2;

# the first argument is the package definition file
my $filename = shift @ARGV;

# read file for package name, version
my ($pkgname, $pkgver) = (undef, undef);
open my $fh, '<', $filename;
while (<$fh>) {
   if (/^\s*name\s*=\s*"(.+?)"\s*$/) {
      $pkgname = $1;
   }
   elsif (/^\s*version\s*=\s*"(.+?)"\s*$/) {
      $pkgver = $1;
   }
   elsif (/^\[(?!package)/) {
      last;
   }
}
close($fh);

################################################################################
# build package (we're running inside the repo directory, so auto-output is fine)

system("holo-build <$filename");

################################################################################
# clean earlier versions of this package

my $package_file = "$pkgname-$pkgver-any.pkg.tar.xz";
for my $other_file (glob("$pkgname-*.pkg.tar.xz")) {
   # check that this is not the latest version of the package
   next if $other_file eq $package_file;
   # check that this is really a file for this package, not for another package
   # whose name starts with that of the current package (globs can't tell that
   # apart)
   next if $other_file !~ m{^\Q$pkgname\E-[0-9.]+-[0-9]+-.*\.pkg\.tar\.xz};
   say "Cleaning up $other_file (looks like an old version of $pkgname-$pkgver)";
   unlink $other_file;
}

