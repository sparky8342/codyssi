#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

open my $fh, "<", "inputs/view_problem_17_input" or die "$!";

#open my $fh, "<", "test.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my %graph;

foreach my $line (@lines) {
    $line =~ /^(\w+)\s->\s(\w+)\s\|\s(\d+)$/;
    push @{ $graph{$1} }, [ $2, $3 ];
}

# part 1
my @queue   = ( { pos => 'STT', distance => 0 } );
my %visited = ( 'STT' => 1 );
my @distances;
while ( scalar @queue ) {
    my $entry = shift @queue;
    push @distances, $entry->{distance};
    for my $neighbour ( @{ $graph{ $entry->{pos} } } ) {
        my ($npos) = @$neighbour;
        if ( !exists( $visited{$npos} ) ) {
            push @queue, { pos => $npos, distance => $entry->{distance} + 1 };
            $visited{$npos} = 1;
        }
    }
}
@distances = sort { $b <=> $a } @distances;
print $distances[0] * $distances[1] * $distances[2] . "\n";
