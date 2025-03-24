#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_12_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my $ab = 0;
for my $line (@lines) {
    for my $char ( split //, $line ) {
        if (   ( $char ge 'a' && $char le 'z' )
            || ( $char ge 'A' && $char le 'Z' ) )
        {
            $ab++;
        }
    }
}
print "$ab\n";
