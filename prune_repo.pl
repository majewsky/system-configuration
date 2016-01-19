#!/usr/bin/perl
use strict;
use warnings;
use v5.20;

use autodie qw(:all);

# regexes for matching package file names
my $pkgname_rx = qr/[a-z0-9@._+][a-z0-9@._+-]*/;
my $pkgver_rx = qr/(?:[0-9]+:)?[a-zA-Z0-9._]+-[0-9]+/;
my $pkgarch_rx = qr/(?:any|i686|x86_64)/;
my $pkgfile_rx = qr{($pkgname_rx)-($pkgver_rx)-($pkgarch_rx)\.pkg\.tar\.xz};



# for all package files...
my @pkgfiles = glob('*.pkg.tar.xz');
my %packages;
my %current_pkgver;
for my $pkgfile (@pkgfiles) {
   # parse file name
   my ($pkgname, $pkgver, $pkgarch) = $pkgfile =~ $pkgfile_rx;

   # track which package versions exist for the same $pkgname
   push @{ $packages{$pkgname} }, [ $pkgver, $pkgarch ];

   # find the largest (i.e. current $pkgver) for this package
   unless (exists $current_pkgver{$pkgname}) {
      $current_pkgver{$pkgname} = $pkgver;
   } else {
      # compare $current_pkgver{$pkgname} and $pkgver using vercmp
      open my $fh, '-|', 'vercmp', $pkgver, $current_pkgver{$pkgname};
      chomp(my $cmp = <$fh>);
      close($fh);
      if ($cmp > 0) {
         # $pkgver is newer than what we've previously seen
         $current_pkgver{$pkgname} = $pkgver;
      }
   }
}

# for all packages...
for my $pkgname (sort keys %packages) {
   my $current_pkgver = $current_pkgver{$pkgname};

   # ...keep only the most current package file
   for my $variant (@{ $packages{$pkgname} }) {
      my ($pkgver, $pkgarch) = @$variant;
      if ($pkgver ne $current_pkgver) {
         my $pkgfile = "$pkgname-$pkgver-$pkgarch.pkg.tar.xz";
         say "Cleaning up $pkgfile (looks like an old version of $pkgname-$current_pkgver)";
         unlink $pkgfile;
      }
   }
}

# discard signature files for deleted packages
for my $sigfile (glob '*.pkg.tar.xz.sig') {
   my $pkgfile = $sigfile =~ s/\.sig$//r;
   unlink $sigfile unless -f $pkgfile;
}
