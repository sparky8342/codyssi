#!/usr/bin/perl
use strict;
use warnings;

sub range_total {
    my ($range) = @_;
    my ( $start, $end ) = split /\-/, $range;
    return $end - $start + 1;
}

sub max {
    return $_[0] > $_[1] ? $_[0] : $_[1];
}

open my $fh, "<", "inputs/view_problem_7_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# part 1
my $total = 0;
for my $line (@lines) {
    my @ranges = split /\s/, $line;
    $total += range_total( $ranges[0] );
    $total += range_total( $ranges[1] );
}
print "$total\n";

# part 2
$total = 0;
for my $line (@lines) {
    $line =~ /^(\d+)\-(\d+) (\d+)\-(\d+)$/;
    my ( $r1, $r2, $r3, $r4 ) = ( $1, $2, $3, $4 );
    if ( $r1 > $r3 ) {
        ( $r1, $r2, $r3, $r4 ) = ( $r3, $r4, $r1, $r2 );
    }
    if ( $r2 >= $r3 ) {
        $total += max( $r2, $r4 ) - $r1 + 1;
    }
    else {
        $total += $r2 - $r1 + 1;
        $total += $r4 - $r3 + 1;
    }
}
print "$total\n";
