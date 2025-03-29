#!/usr/bin/perl
use strict;
use warnings;

sub bfs {
    my ( $graph, $use_distances ) = @_;
    my @queue   = ( { pos => 'STT', distance => 0 } );
    my %visited = ( 'STT' => 1 );
    my @distances;
    while ( scalar @queue ) {
        my $entry = shift @queue;
        push @distances, $entry->{distance};
        for my $neighbour ( @{ $graph->{ $entry->{pos} } } ) {
            my ( $npos, $dist ) = @$neighbour;
            if ( !exists( $visited{$npos} ) ) {
                if ( !$use_distances ) {
                    $dist = 1;
                }
                push @queue,
                  { pos => $npos, distance => $entry->{distance} + $dist };
                $visited{$npos} = 1;
            }
        }
    }
    @distances = sort { $b <=> $a } @distances;
    return $distances[0] * $distances[1] * $distances[2];
}

sub dfs {
    my ( $graph, $pos, $goal, $distance, $max, $visited ) = @_;

    if ( exists( $visited->{$pos} ) ) {
        if ( $pos eq $goal ) {
            if ( $distance > $$max ) {
                $$max = $distance;
            }
        }
        return;
    }

    $visited->{$pos} = 1;
    for my $neighbour ( @{ $graph->{$pos} } ) {
        my ( $npos, $dist ) = @$neighbour;
        dfs( $graph, $npos, $goal, $distance + $dist, $max, $visited );
    }
    delete( $visited->{$pos} );
}

open my $fh, "<", "inputs/view_problem_17_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my %graph;
foreach my $line (@lines) {
    $line =~ /^(\w+)\s->\s(\w+)\s\|\s(\d+)$/;
    push @{ $graph{$1} }, [ $2, $3 ];
}

# part 1
print bfs( \%graph ) . "\n";

# part 2
print bfs( \%graph, 1 ) . "\n";

# part 3
my $max = 0;
for my $pos ( keys %graph ) {
    dfs( \%graph, $pos, $pos, 0, \$max, {} );
}
print "$max\n";
