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

sub calc_offset_pairs {
    my ( $nums, $symbols ) = @_;
    my $offset = $nums->[0] * 10 + $nums->[1];
    for ( my $i = 2 ; $i < scalar @$nums ; $i += 2 ) {
        my $num = $nums->[$i] * 10 + $nums->[ $i + 1 ];
        if ( $symbols->[ $i / 2 - 1 ] eq '+' ) {
            $offset += $num;
        }
        else {
            $offset -= $num;
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

# part 3
$offset = calc_offset_pairs( \@nums, \@symbols );
print "$offset\n";
