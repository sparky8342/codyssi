#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_10_input" or die "$!";
chomp( my $line = <$fh> );
close $fh;

# parts 1, 2 and 3
my $count    = 0;
my $sum      = 0;
my $total    = 0;
my $last_val = 0;

foreach my $char ( split //, $line ) {
    my $val = 0;
    if ( $char ge 'A' && $char le 'Z' ) {
        $count++;
        $val = ord($char) - 38;
    }
    elsif ( $char ge 'a' && $char le 'z' ) {
        $count++;
        $val = ord($char) - 96;
    }
    else {
        $last_val = $last_val * 2 - 5;
        while ( $last_val < 1 ) {
            $last_val += 52;
        }
        while ( $last_val > 52 ) {
            $last_val -= 52;
        }
        $total += $last_val;
        next;
    }

    $sum   += $val;
    $total += $val;
    $last_val = $val;
}

print "$count\n$sum\n$total\n";
