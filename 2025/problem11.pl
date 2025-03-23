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
my @freq = @frequencies;
foreach my $swap (@swaps) {
    ( $freq[ $swap->[0] ], $freq[ $swap->[1] ] ) =
      ( $freq[ $swap->[1] ], $freq[ $swap->[0] ] );
}
print $freq[$test_index] . "\n";

# part 2
@freq = @frequencies;
push @swaps, $swaps[0];
for ( my $i = 0 ; $i < scalar @swaps - 1 ; $i++ ) {
    (
        $freq[ $swaps[$i]->[0] ],
        $freq[ $swaps[$i]->[1] ],
        $freq[ $swaps[ $i + 1 ]->[0] ]
      )
      = (
        $freq[ $swaps[ $i + 1 ]->[0] ],
        $freq[ $swaps[$i]->[0] ],
        $freq[ $swaps[$i]->[1] ]
      );
}

print $freq[$test_index] . "\n";
