#!/usr/bin/perl
use strict;
use warnings;
use v5.20;

my $text = do { local $/; <STDIN> };
$text =~ s{\$\{(\w+?)\}}{replace_var($1, $&)}eg;
print $text;

sub replace_var {
   # called like replace_var("FOO", "${FOO}")
   my ($key, $match) = @_;

   # if $ENV{FOO} does not exist, don't change anything
   return $match unless defined $ENV{$key};

   # if $ENV{FOO} contains newlines etc., escape them (this is required to
   # generate conformant TOML string literals)
   return $ENV{$key} =~ s{\n}{\\n}gr =~ s{\r}{\\r}gr =~ s{\t}{\\t}gr;
}
