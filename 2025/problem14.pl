#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min);

use Data::Dumper;

open my $fh, "<", "inputs/view_problem_14_input" or die "$!";

#open my $fh, "<", "p14_sample.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @grid;
for my $line (@lines) {
    my $row;
    for my $n ( split / /, $line ) {
        push @$row, $n;
    }
    push @grid, $row;
}

# part 1
my $min  = 999999;
my $size = scalar @{ $grid[0] };
for ( my $i = 0 ; $i < $size ; $i++ ) {
    my $r = 0;
    my $c = 0;
    for ( my $j = 0 ; $j < $size ; $j++ ) {
        $r += $grid[$i][$j];
        $c += $grid[$j][$i];
    }
    if ( $r < $min ) {
        $min = $r;
    }
    if ( $c < $min ) {
        $min = $c;
    }
}
print "$min\n";

# part 2
for ( my $i = 1 ; $i < 15 ; $i++ ) {
    $grid[0][$i] += $grid[0][ $i - 1 ];
    $grid[$i][0] += $grid[ $i - 1 ][0];
}
for ( my $y = 1 ; $y < 15 ; $y++ ) {
    for ( my $x = 1 ; $x < 15 ; $x++ ) {
        $grid[$y][$x] =
          min( $grid[ $y - 1 ][$x], $grid[$y][ $x - 1 ] ) + $grid[$y][$x];
    }
}
print $grid[14][14] . "\n";
