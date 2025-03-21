#!/usr/bin/perl
use strict;
use warnings;

sub base_from {
    my ( $num, $base ) = @_;
    my $t = 0;
    for my $digit ( split( //, lc($num) ) ) {
        $t =
          $base * $t + index( "0123456789abcdefghijklmnopqrstuvwxyz", $digit );
    }
    return $t;
}

open my $fh, "<", "inputs/view_problem_3_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @nums = map { [ split /\s/, $_ ] } @lines;

# part 1
my $sum = 0;
map { $sum += $_->[1] } @nums;
print "$sum\n";

# part 2
$sum = 0;
foreach my $num (@nums) {
    my ( $n, $base ) = @$num;
    $sum += base_from( $n, $base );
}
print "$sum\n";
