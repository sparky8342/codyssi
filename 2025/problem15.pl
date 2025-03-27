#!/usr/bin/perl
use strict;
use warnings;

sub base_from {
    my ( $num, $base ) = @_;
    my $result = 0;
    for my $digit ( split( //, $num ) ) {
        $result =
          $base * $result +
          index(
            "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz",
            $digit );
    }
    return $result;
}

sub base_to {
    my ( $num, $base ) = @_;
    my $result = "";
    do {
        $result =
          ( '0' .. '9', 'A' .. 'Z', 'a' .. 'z', '!', '@', '#', '$', '%', '^' )
          [ $num % $base ] . $result;
    } while $num = int( $num / $base );
    return $result;
}

open my $fh, "<", "inputs/view_problem_15_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @nums = map { [ split /\s/, $_ ] } @lines;

# part 1
my $max = 0;
foreach my $num (@nums) {
    my ( $n, $base ) = @$num;
    my $base10 = base_from( $n, $base );
    if ( $base10 > $max ) {
        $max = $base10;
    }
}
print "$max\n";

# part 2
my $sum = 0;
foreach my $num (@nums) {
    my ( $n, $base ) = @$num;
    $sum += base_from( $n, $base );
}
print base_to( $sum, 68 ) . "\n";

# part 3
print int( $sum**( 1 / 4 ) + 1 ) . "\n";
