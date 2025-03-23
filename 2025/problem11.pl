#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_11_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @frequencies;
my @swaps;
my $i = 0;
while ( $lines[$i] ne '' ) {
    push @frequencies, $lines[$i];
    $i++;
}
$i++;
while ( $lines[$i] ne '' ) {
    $lines[$i] =~ /^(\d+)\-(\d+)$/;
    push @swaps, [ $1 - 1, $2 - 1 ];
    $i++;
}
$i++;
my $test_index = $lines[$i] - 1;

# part 1
foreach my $swap (@swaps) {
    ( $frequencies[ $swap->[0] ], $frequencies[ $swap->[1] ] ) =
      ( $frequencies[ $swap->[1] ], $frequencies[ $swap->[0] ] );
}
print $frequencies[$test_index] . "\n";
