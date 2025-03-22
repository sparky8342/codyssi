#!/usr/bin/perl
use strict;
use warnings;

sub manhattan {
    my ( $coord1, $coord2 ) = @_;
    return
      abs( $coord1->[0] - $coord2->[0] ) + abs( $coord1->[1] - $coord2->[1] );
}

sub find_islands {
    my ( $coord, $coords ) = @_;

    my $closest_dist = 999999;
    my $closest;
    my $furthest_dist = 0;
    for ( my $i = 0 ; $i < scalar @$coords ; $i++ ) {
        my $dist = manhattan( $coord, $coords->[$i] );
        if ( $dist == 0 ) {
            next;
        }
        elsif ( $dist < $closest_dist ) {
            $closest_dist = $dist;
            $closest      = $i;
        }
        elsif ( $dist == $closest_dist ) {
            if ( $coords->[$i]->[0] < $closest->[0] ) {
                $closest = $coords->[$i];
            }
            elsif ($coords->[$i]->[0] == $closest->[0]
                && $coords->[$i]->[1] < $closest->[1] )
            {
                $closest = $coords->[$i];
            }
        }
        elsif ( $dist > $furthest_dist ) {
            $furthest_dist = $dist;
        }
    }

    return ( $closest_dist, $closest, $furthest_dist );
}

open my $fh, "<", "inputs/view_problem_9_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @coords;
for my $line (@lines) {
    push @coords, [ split /, /, substr( $line, 1, length($line) - 2 ) ];
}

# part 1 and 2
my $coord = [ 0, 0 ];
my ( $closest_distance, $closest, $furthest_distance ) =
  find_islands( $coord, \@coords );
print $furthest_distance - $closest_distance . "\n";

# part 2
$coord = $coords[$closest];
($closest_distance) = find_islands( $coord, \@coords );
print "$closest_distance\n";

# part 3
$coord = [ 0, 0 ];
my $total = 0;
while ( scalar @coords ) {
    my ( $closest_distance, $closest ) = find_islands( $coord, \@coords );
    $total += $closest_distance;
    $coord = $coords[$closest];
    splice( @coords, $closest, 1 );
}
print "$total\n";
