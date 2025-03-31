#!/usr/bin/perl
use strict;
use warnings;

sub add_node {
    my ( $node, $new_node, $seq ) = @_;
    if ( ref($seq) ) {
        push @$seq, $node->{code};
    }
    if ( $new_node->{id} <= $node->{id} ) {
        if ( defined( $node->{left} ) ) {
            add_node( $node->{left}, $new_node, $seq );
        }
        else {
            $node->{left} = $new_node;
        }
    }
    else {
        if ( defined( $node->{right} ) ) {
            add_node( $node->{right}, $new_node, $seq );
        }
        else {
            $node->{right} = $new_node;
        }
    }
}

sub find_path {
    my ( $node, $find_node, $seq ) = @_;
    push @$seq, $node->{code};
    if ( $node->{code} eq $find_node->{code} ) {
        return;
    }
    elsif ( $find_node->{id} <= $node->{id} ) {
        if ( defined( $node->{left} ) ) {
            find_path( $node->{left}, $find_node, $seq );
        }
    }
    elsif ( defined( $node->{right} ) ) {
        find_path( $node->{right}, $find_node, $seq );
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

# part 2
my @seq;
my $new_node = { code => '', id => 500000, left => undef, right => undef };
add_node( $head, $new_node, \@seq );
print join( "-", @seq ) . "\n";

# part 3
my $line_no = ( scalar @lines ) - 2;
$lines[$line_no] =~ /^(\w+) \| (\d+)$/;
my $node1 = { code => $1, id => $2, left => undef, right => undef };
my @path1;
find_path( $head, $node1, \@path1 );
@path1 = reverse @path1;

$line_no++;
$lines[$line_no] =~ /^(\w+) \| (\d+)$/;
my $node2 = { code => $1, id => $2, left => undef, right => undef };
my @path2;
find_path( $head, $node2, \@path2 );
@path2 = reverse @path2;

outer:
foreach my $code1 (@path1) {
    foreach my $code2 (@path2) {
        if ( $code1 eq $code2 ) {
            print "$code1\n";
            last outer;
        }
    }
}
