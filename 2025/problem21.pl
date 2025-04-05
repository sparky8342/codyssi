#!/usr/bin/perl
use strict;
use warnings;
use Math::BigInt;

sub add_edge {
    my ( $edges, $from, $to ) = @_;
    push @{ $edges->{$from} }, $to;
}

sub create_graph {
    my ($lines) = @_;

    my $edges = {};

    $lines->[0] =~ /^S1 : 0 -> (\d+) : FROM START TO END$/;
    my $end = $1;

    my $node = "S1_0";

    for ( my $i = 0 ; $i < $end ; $i++ ) {
        add_edge( $edges, sprintf( "S1_%d", $i ), sprintf( "S1_%d", $i + 1 ) );
    }

    for ( my $i = 1 ; $i < scalar @$lines ; $i++ ) {
        $lines->[$i] =~ /^S(\d+) : (\d+) -> (\d+) : FROM S(\d+) TO S(\d+)$/;
        my ( $id, $start, $end, $from_id, $to_id ) = ( $1, $2, $3, $4, $5 );

        add_edge(
            $edges,
            sprintf( "S%d_%d", $from_id, $start ),
            sprintf( "S%d_%d", $id,      $start )
        );

        for ( my $i = $start ; $i < $end ; $i++ ) {
            add_edge(
                $edges,
                sprintf( "S%d_%d", $id, $i ),
                sprintf( "S%d_%d", $id, $i + 1 )
            );
        }

        add_edge(
            $edges,
            sprintf( "S%d_%d", $id,    $end ),
            sprintf( "S%d_%d", $to_id, $end )
        );
    }

    return ( $edges, "S1_0", "S1_$end" );
}

sub dfs_steps {
    my ( $edges, $node, $steps ) = @_;

    if ( $steps == 0 ) {
        return [$node];
    }

    my @nodes;
    for my $next_node ( @{ $edges->{$node} } ) {
        my $n = dfs_steps( $edges, $next_node, $steps - 1 );
        @nodes = ( @nodes, @$n );
    }

    return \@nodes;
}

sub get_next_nodes {
    my ( $edges, $node, $moves ) = @_;

    my @next_nodes;
    for my $move (@$moves) {
        @next_nodes = ( @next_nodes, @{ dfs_steps( $edges, $node, $move ) } );
    }

    my %n = map { $_ => 1 } @next_nodes;
    @next_nodes = keys %n;

    return \@next_nodes;
}

sub dfs {
    my ( $edges, $node, $end_node, $moves, $cache ) = @_;

    if ( exists( $cache->{$node} ) ) {
        return $cache->{$node};
    }

    if ( $node eq $end_node ) {
        return 1;
    }

    my $next_nodes = get_next_nodes( $edges, $node, $moves );

    my $paths = Math::BigInt->new(0);
    for my $next_node (@$next_nodes) {
        $paths += dfs( $edges, $next_node, $end_node, $moves, $cache );
    }

    $cache->{$node} = $paths;
    return $paths;
}

sub find_path_no {
    my ( $edges, $start_node, $end_node, $moves, $target, $min, $max ) = @_;

    my $node = $start_node;

    my @path = ($node);

    my %cache;

    while ( $node ne $end_node ) {
        my $next_nodes = get_next_nodes( $edges, $node, $moves );

        my @counts;

        foreach my $next_node (@$next_nodes) {
            my $paths = dfs( $edges, $next_node, $end_node, $moves, \%cache );
            push @counts, { node => $next_node, paths => $paths };
        }

        @counts = sort {
            $b->{node} =~ /^S(\d+)_(\d+)$/;
            my ( $b_id, $b_step ) = ( $1, $2 );

            $a->{node} =~ /^S(\d+)_(\d+)$/;
            my ( $a_id, $a_step ) = ( $1, $2 );

            return $a_id <=> $b_id || $a_step <=> $b_step;
        } @counts;

        my $pos = $min;
        foreach my $c (@counts) {
            $c->{min} = $pos;
            $pos += $c->{paths} - 1;
            $c->{max} = $pos;
            $pos++;
        }

        foreach my $c (@counts) {
            if ( $c->{min} <= $target && $target <= $c->{max} ) {
                push @path, $c->{node};
                $node = $c->{node};
                $min  = $c->{min};
                $max  = $c->{max};
                last;
            }
        }
    }

    return join( "-", @path );
}

open my $fh, "<", "inputs/view_problem_21_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

( pop @lines ) =~ /^Possible Moves : (.*)$/;
my @moves = split /, /, $1;
pop @lines;

# part 1
$lines[0] =~ /^S1 : 0 -> (\d+) : FROM START TO END$/;
my $end = $1;

my @dp = (0) x ( $end + 1 );
$dp[0] = Math::BigInt->new(1);
for ( my $i = 0 ; $i <= $end ; $i++ ) {
    if ( $dp[$i] > 0 ) {
        for my $move (@moves) {
            if ( $i + $move <= $end ) {
                $dp[ $i + $move ] += $dp[$i];
            }
        }
    }
}
printf $dp[$end] . "\n";

# part 2
my ( $edges, $start_node, $end_node ) = create_graph( \@lines );
my $paths = dfs( $edges, $start_node, $end_node, \@moves, {} );
print "$paths\n";

# part 3
my $target = Math::BigInt->new(100000000000000000000000000000);
my $path =
  find_path_no( $edges, $start_node, $end_node, \@moves, $target,
    Math::BigInt->new(1), $paths );
print "$path\n";
