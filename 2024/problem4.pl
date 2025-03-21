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

# part 2 and 3
my @queue   = ("STT");
my %visited = ( "STT" => 0 );

my $steps = 1;
while ( scalar(@queue) > 0 ) {
    my $l = scalar @queue;
    for ( 1 .. $l ) {
        my $location = shift @queue;
        for my $destination ( @{ $graph{$location} } ) {
            if ( exists( $visited{$destination} ) ) {
                next;
            }
            push @queue, $destination;
            $visited{$destination} = $steps;
        }
    }
    $steps++;
}

$size = 0;
foreach my $value ( values %visited ) {
    if ( $value <= 3 ) {
        $size++;
    }
}
print "$size\n";

# part 3
$size = 0;
map { $size += $_ } values %visited;
print "$size\n";
