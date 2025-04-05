#!/usr/bin/perl
use strict;
use warnings;
use Math::BigInt;

sub create_graph {
    my ($lines) = @_;

    my %node_cache;    # for building the graph only

    $lines->[0] =~ /^S1 : 0 -> (\d+) : FROM START TO END$/;
    my $end = $1;

    my $head = { id => "S1_0" };
    $node_cache{"S1_0"} = $head;
    my $node = $head;

    for ( 1 .. $end ) {
        my $next_node = { id => "S1_$_" };
        $node_cache{"S1_$_"} = $next_node;
        $node->{next}        = [$next_node];
        $node                = $node->{next}->[0];
    }

    my $end_node = $node;

    for ( my $i = 1 ; $i < scalar @$lines ; $i++ ) {
        $lines->[$i] =~ /^S(\d+) : (\d+) -> (\d+) : FROM S(\d+) TO S(\d+)$/;
        my ( $id, $start, $end, $from_id, $to_id ) = ( $1, $2, $3, $4, $5 );
        my $start_node = { id => "S$id" . "_" . $start };
        $node_cache{ "S$id" . "_" . $start } = $start_node;
        my $node = $start_node;
        for ( my $j = $start + 1 ; $j <= $end ; $j++ ) {
            my $next_node = { id => "S$id" . "_" . $j };
            $node_cache{ "S$id" . "_" . $j } = $next_node;
            $node->{next}                    = [$next_node];
            $node                            = $node->{next}->[0];
        }

        # link up path
        my $path_node = $node_cache{ "S$from_id" . "_" . $start };
        unshift @{ $path_node->{next} }, $start_node;

        $path_node = $node_cache{ "S$to_id" . "_" . $end };
        push @{ $node->{next} }, $path_node;
    }

    return ( $head, $end_node );
}

sub dfs_steps {
    my ( $node, $steps ) = @_;

    if ( $steps == 0 ) {
        return [$node];
    }

    my @nodes;
    for my $next_node ( @{ $node->{next} } ) {
        my $n = dfs_steps( $next_node, $steps - 1 );
        @nodes = ( @nodes, @$n );
    }

    return \@nodes;
}

sub get_next_nodes {
    my ( $node, $moves ) = @_;

    my @next_nodes;
    for my $move (@$moves) {
        @next_nodes = ( @next_nodes, @{ dfs_steps( $node, $move ) } );
    }

    my %n = map { $_->{id} => $_ } @next_nodes;
    @next_nodes = values %n;

    return \@next_nodes;
}

sub dfs {
    my ( $node, $end_node, $moves, $cache ) = @_;

    if ( exists( $cache->{ $node->{id} } ) ) {
        return $cache->{ $node->{id} };
    }

    if ( $node->{id} eq $end_node->{id} ) {
        return 1;
    }

    my $next_nodes = get_next_nodes( $node, $moves );

    my $paths = Math::BigInt->new(0);
    for my $next_node (@$next_nodes) {
        $paths += dfs( $next_node, $end_node, $moves, $cache );
    }

    $cache->{ $node->{id} } = $paths;
    return $paths;
}

sub find_path_no {
    my ( $head, $end_node, $moves, $target, $min, $max ) = @_;

    my $node = $head;

    my @path = ( $head->{id} );

    my %cache;

    while ( $node->{id} ne $end_node->{id} ) {
        my $next_nodes = get_next_nodes( $node, $moves );

        my @counts;

        foreach my $next_node (@$next_nodes) {
            my $paths = dfs( $next_node, $end_node, $moves, \%cache );
            push @counts, { node => $next_node, paths => $paths };
        }

        @counts = sort {
            $b->{node}->{id} =~ /^S(\d+)_(\d+)$/;
            my ( $b_id, $b_step ) = ( $1, $2 );

            $a->{node}->{id} =~ /^S(\d+)_(\d+)$/;
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
                push @path, $c->{node}->{id};
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
my ( $head, $end_node ) = create_graph( \@lines );
my $paths = dfs( $head, $end_node, \@moves, {} );
print "$paths\n";

# part 3
my $target = Math::BigInt->new(100000000000000000000000000000);
my $path =
  find_path_no( $head, $end_node, \@moves, $target, Math::BigInt->new(1),
    $paths );
print "$path\n";
