#!/usr/bin/perl
use strict;
use warnings;

sub calc_offset {
    my ( $nums, $symbols ) = @_;
    my $offset = $nums->[0];
    for ( my $i = 1 ; $i < scalar @$nums ; $i++ ) {
        if ( $symbols->[ $i - 1 ] eq '+' ) {
            $offset += $nums->[$i];
        }
        else {
            $offset -= $nums->[$i];
        }
    }
    return $offset;
}

open my $fh, "<", "inputs/view_problem_5_input" or die "$!";
chomp( my @nums = <$fh> );
close $fh;

my @symbols = split //, pop @nums;

# part 1
my $offset = calc_offset( \@nums, \@symbols );
print "$offset\n";

# part 2
@symbols = reverse @symbols;
$offset  = calc_offset( \@nums, \@symbols );
print "$offset\n";
