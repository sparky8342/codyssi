#!/usr/bin/perl
use strict;
use warnings;
use Math::BigInt;

use Data::Dumper;

open my $fh, "<", "inputs/view_problem_21_input" or die "$!";

#open my $fh, "<", "test.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# part 1
$lines[0] =~ /^S1 : 0 -> (\d+) : FROM START TO END$/;
my $end = $1;

$lines[ scalar @lines - 1 ] =~ /^Possible Moves : (.*)$/;
my @moves = split /, /, $1;

my @dp = ( Math::BigInt->new(0) ) x ( $end + 1 );
for my $move (@moves) {
    $dp[$move] = 1;
}
for ( my $i = 1 ; $i <= $end ; $i++ ) {
    if ( $dp[$i] > 0 ) {
        for my $move (@moves) {
            if ( $i + $move <= $end ) {
                $dp[ $i + $move ] += $dp[$i];
            }
        }
    }
}
printf $dp[$end] . "\n";

