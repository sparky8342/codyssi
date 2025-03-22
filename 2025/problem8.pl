#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_8_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# part 1
my $units = 0;
for my $line (@lines) {
    for my $char ( split //, $line ) {
        $units += ord($char) - 64;
    }
}
print "$units\n";

# part 2
$units = 0;
for my $line (@lines) {
    my $keep = int( length($line) / 10 );
    my $num  = length($line) - $keep * 2;
    my $compressed =
        substr( $line, 0, $keep )
      . $num
      . substr( $line, length($line) - $keep, $keep );
    for my $char ( split //, $compressed ) {
        if ( $char eq '0' ) {
            next;
        }
        elsif ( $char ge '1' && $char le '9' ) {
            $units += $char;
        }
        else {
            $units += ord($char) - 64;
        }
    }
}
print "$units\n";
