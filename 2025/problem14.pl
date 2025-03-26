#!/usr/bin/perl
use strict;
use warnings;

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
