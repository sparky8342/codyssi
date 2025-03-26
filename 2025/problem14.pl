#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(min);

open my $fh, "<", "inputs/view_problem_14_input" or die "$!";
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
my $size = scalar @{ $grid[0] };

# part 1
my $min = 999999;
for ( my $i = 0 ; $i < $size ; $i++ ) {
    my $r = 0;
    my $c = 0;
    for ( my $j = 0 ; $j < $size ; $j++ ) {
        $r += $grid[$i][$j];
        $c += $grid[$j][$i];
    }
    $min = min( $min, $r );
    $min = min( $min, $c );
}
print "$min\n";

# part 2 and 3
for ( my $i = 1 ; $i < $size ; $i++ ) {
    $grid[0][$i] += $grid[0][ $i - 1 ];
    $grid[$i][0] += $grid[ $i - 1 ][0];
}
for ( my $y = 1 ; $y < $size ; $y++ ) {
    for ( my $x = 1 ; $x < $size ; $x++ ) {
        $grid[$y][$x] =
          min( $grid[ $y - 1 ][$x], $grid[$y][ $x - 1 ] ) + $grid[$y][$x];
    }
}
print $grid[14][14] . "\n";
print $grid[ $size - 1 ][ $size - 1 ] . "\n";
