#!/usr/bin/perl
use strict;
use warnings;

sub max {
    return $_[0] > $_[1] ? $_[0] : $_[1];
}

sub ranges_cross {
    my ( $range_a, $range_b ) = @_;
    if ( $range_a->[0] > $range_b->[0] ) {
        ( $range_a, $range_b ) = ( $range_b, $range_a );
    }
    if ( $range_a->[1] >= $range_b->[0] ) {
        return 1;
    }
    else {
        return 0;
    }
}

sub range_combine {
    my ( $range_a, $range_b ) = @_;
    if ( $range_a->[0] > $range_b->[0] ) {
        ( $range_a, $range_b ) = ( $range_b, $range_a );
    }
    return [ $range_a->[0], max( $range_a->[1], $range_b->[1] ) ];
}

sub range_multi_combine {
    my ($ranges) = @_;

    my $new_ranges = [];

  outer:
    while ( scalar @$ranges ) {
        my $range = shift @$ranges;
        for ( my $i = 0 ; $i < scalar @$ranges ; $i++ ) {
            if ( ranges_cross( $ranges->[$i], $range ) ) {
                my $combined = range_combine( $ranges->[$i], $range );
                splice( @$ranges, $i, 1, $combined );
                next outer;
            }
        }
        push @$new_ranges, $range;
    }

    return $new_ranges;
}

open my $fh, "<", "inputs/view_problem_7_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @ranges;
for my $line (@lines) {
    $line =~ /^(\d+)\-(\d+) (\d+)\-(\d+)$/;
    my $range_a = [ $1, $2 ];
    my $range_b = [ $3, $4 ];
    push @ranges, [ $range_a, $range_b ];
}

# part 1
my $total = 0;
for my $pair (@ranges) {
    my ( $range_a, $range_b ) = @$pair;
    $total += $range_a->[1] - $range_a->[0] + 1;
    $total += $range_b->[1] - $range_b->[0] + 1;
}
print "$total\n";

# part 2
$total = 0;
for my $pair (@ranges) {
    my ( $range_a, $range_b ) = @$pair;

    if ( ranges_cross( $range_a, $range_b ) ) {
        my $range = range_combine( $range_a, $range_b );
        $total += $range->[1] - $range->[0] + 1;
    }
    else {
        $total += $range_a->[1] - $range_a->[0] + 1;
        $total += $range_b->[1] - $range_b->[0] + 1;
    }
}
print "$total\n";

# part 3
my $best = 0;
for ( my $i = 0 ; $i < scalar @ranges - 1 ; $i++ ) {
    my ( $range_a, $range_b ) = @{ $ranges[$i] };
    my ( $range_c, $range_d ) = @{ $ranges[ $i + 1 ] };

    my $group =
      range_multi_combine( [ $range_a, $range_b, $range_c, $range_d ] );

    my $total = 0;
    for my $range (@$group) {
        my ( $start, $end ) = @$range;
        $total += $end - $start + 1;
    }
    if ( $total > $best ) {
        $best = $total;
    }
}
print "$best\n";
