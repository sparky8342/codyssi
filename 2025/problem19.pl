#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

sub add_node {
    my ( $node, $new_node ) = @_;
    if ( $new_node->{id} <= $node->{id} ) {
        if ( defined( $node->{left} ) ) {
            add_node( $node->{left}, $new_node );
        }
        else {
            $node->{left} = $new_node;
        }
    }
    else {
        if ( defined( $node->{right} ) ) {
            add_node( $node->{right}, $new_node );
        }
        else {
            $node->{right} = $new_node;
        }
    }
}

sub bfs {
    my ($head) = @_;

    my $occupied_layers = 0;
    my @queue           = ($head);
    my $max_sum         = 0;

    while ( scalar @queue ) {
        $occupied_layers++;
        my $layer_sum = 0;
        my $l         = scalar @queue;
        for ( 1 .. $l ) {
            my $node = shift @queue;
            $layer_sum += $node->{id};
            if ( defined( $node->{left} ) ) {
                push @queue, $node->{left};
            }
            if ( defined( $node->{right} ) ) {
                push @queue, $node->{right};
            }
        }
        if ( $layer_sum > $max_sum ) {
            $max_sum = $layer_sum;
        }
    }

    return $max_sum * $occupied_layers;
}

open my $fh, "<", "inputs/view_problem_19_input" or die "$!";

#open my $fh, "<", "test.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

$lines[0] =~ /^(\w+) \| (\d+)$/;
my $head = { code => $1, id => $2, left => undef, right => undef };

for ( my $i = 1 ; $i < scalar @lines ; $i++ ) {
    if ( $lines[$i] eq '' ) {
        last;
    }
    $lines[$i] =~ /^(\w+) \| (\d+)$/;
    my $node = { code => $1, id => $2, left => undef, right => undef };
    add_node( $head, $node );
}

# part 1
print bfs($head) . "\n";
