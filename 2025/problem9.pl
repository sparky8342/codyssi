#!/usr/bin/perl
use strict;
use warnings;

sub manhattan {
    my ( $coord1, $coord2 ) = @_;
    return
      abs( $coord1->[0] - $coord2->[0] ) + abs( $coord1->[1] - $coord2->[1] );
}

open my $fh, "<", "inputs/view_problem_9_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @coords;
for my $line (@lines) {
    push @coords, [ split /, /, substr( $line, 1, length($line) - 2 ) ];
}

# part 1 and 2
my $closest = 999999;
my $closest_coord;
my $furthest = 0;
foreach my $coord (@coords) {
    my $dist = abs( $coord->[0] ) + abs( $coord->[1] );
    if ( $dist < $closest ) {
        $closest       = $dist;
        $closest_coord = $coord;
    }
    elsif ( $dist == $closest ) {
        if ( $coord->[0] < $closest_coord->[0] ) {
            $closest_coord = $coord;
        }
        elsif ($coord->[0] == $closest_coord->[0]
            && $coord->[1] < $closest_coord->[1] )
        {
            $closest_coord = $coord;
        }
    }
    elsif ( $dist > $furthest ) {
        $furthest = $dist;
    }
}
print $furthest - $closest . "\n";

# part 2
$closest = 999999;
foreach my $coord (@coords) {
    my $dist = manhattan( $coord, $closest_coord );
    if ( $dist > 0 && $dist < $closest ) {
        $closest = $dist;
    }
}
print "$closest\n";
