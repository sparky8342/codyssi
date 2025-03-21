#!/usr/bin/perl
use strict;
use warnings;

sub base_from {
    my ( $num, $base ) = @_;
    my $result = 0;
    for my $digit ( split( //, lc($num) ) ) {
        $result =
          $base * $result +
          index( "0123456789abcdefghijklmnopqrstuvwxyz", $digit );
    }
    return $result;
}

sub base_to {
    my ( $num, $base ) = @_;
    my $result = "";
    do {
        $result =
          ( '0' .. '9', 'A' .. 'Z', 'a' .. 'z', '!', '@', '#' )[ $num % $base ]
          . $result;
    } while $num = int( $num / $base );
    return $result;
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

# part 3
print base_to( $sum, 65 ) . "\n";
