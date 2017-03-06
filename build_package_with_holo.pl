#!/usr/bin/perl
use strict;
use warnings;
use v5.20;

use autodie qw(:all);

# the first argument is the package definition file
my $filename = shift @ARGV;

# use holo-build to find the package file name
open my $fh, '-|', 'sh', '-c', "holo-build --suggest-filename $filename";
chomp(my $package_file = <$fh>);
close($fh);

# read makepkg.conf to see if signing is wanted
my ($sign, $gpg_key) = (0, undef);
open $fh, '<', '/etc/makepkg.conf';
while (<$fh>) {
   if (/^\s*BUILDENV\s*=\s*\((.+?)\)\s*$/) {
      $sign = $1 =~ /\b(?<!!)sign\b/;
   }
   elsif (/^\s*GPGKEY\s*=\s*"(.+?)"\s*$/) {
      $gpg_key = $1;
   }
}
close($fh);

################################################################################
# build package if it's not yet there
#
# (we're running inside the repo directory, so auto-output is fine)

my $just_created = 0;

if (not -f $package_file) {
   system("holo-build $filename");
   $just_created = 1;
}
if ($sign and not -f "$package_file.sig") {
   system("gpg", "--detach-sign", "--use-agent", ($gpg_key ? ("-u", $gpg_key) : ()), "--no-armor", $package_file);
   $just_created = 1;
}
if ($just_created) {
   system qw(repo-add -R -n holograms.db.tar.xz), $package_file;
}
