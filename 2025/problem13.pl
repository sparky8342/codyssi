#!/usr/bin/perl
use strict;
use warnings;

sub run_transactions {
    my ( $people, $transactions, $mode ) = @_;
    $people = {%$people};
    for my $transaction (@$transactions) {
        my ( $from, $to, $amount ) = @$transaction;
        if ( $mode == 1 && $people->{$from} < $amount ) {
            $amount = $people->{$from};
        }
        $people->{$from} -= $amount;
        $people->{$to}   += $amount;
    }
    my @balances = sort { $b <=> $a } values %$people;
    return $balances[0] + $balances[1] + $balances[2];
}

open my $fh, "<", "inputs/view_problem_13_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# parse data
my %people;
my $i;
for ( $i = 0 ; $i < scalar @lines ; $i++ ) {
    if ( $lines[$i] =~ /^([A-Za-z-]+) HAS (\d+)$/ ) {
        $people{$1} = $2;
    }
    else {
        last;
    }
}
$i++;
my @transactions;
for ( ; $i < scalar @lines ; $i++ ) {
    $lines[$i] =~ /^FROM ([A-Za-z-]+) TO ([A-Za-z-]+) AMT (\d+)$/;
    push @transactions, [ $1, $2, $3 ];
}

# part 1
my $top_three = run_transactions( \%people, \@transactions, 0 );
print "$top_three\n";

# part 2
$top_three = run_transactions( \%people, \@transactions, 1 );
print "$top_three\n";
