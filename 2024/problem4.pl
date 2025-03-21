#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_4_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my %graph;
for my $line (@lines) {
    my @pair = split / <-> /, $line;
    push @{ $graph{ $pair[0] } }, $pair[1];
    push @{ $graph{ $pair[1] } }, $pair[0];
}

# part 1
my $size = keys %graph;
print "$size\n";

# part 2
my @queue   = ("STT");
my %visited = ( "STT" => 1 );

for ( 1 .. 3 ) {
    my @next_queue;
    for my $location (@queue) {
        for my $destination ( @{ $graph{$location} } ) {
            if ( exists( $visited{$destination} ) ) {
                next;
            }
            push @next_queue, $destination;
            $visited{$destination} = 1;
        }
    }
    @queue = @next_queue;
}

$size = keys %visited;
print "$size\n";
