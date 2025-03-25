#!/usr/bin/perl
use strict;
use warnings;

sub run_transactions {
    my ( $people, $transactions, $no_negative ) = @_;
    for my $transaction (@$transactions) {
        my ( $from, $to, $amount ) = @$transaction;
        if ( $no_negative && $people->{$from} < $amount ) {
            $amount = $people->{$from};
        }
        $people->{$from} -= $amount;
        $people->{$to}   += $amount;
    }
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
my $people_copy = {%people};
run_transactions( $people_copy, \@transactions );
my @balances = sort { $b <=> $a } values %$people_copy;
print $balances[0] + $balances[1] + $balances[2] . "\n";

# part 2
$people_copy = {%people};
run_transactions( $people_copy, \@transactions, 1 );
@balances = sort { $b <=> $a } values %$people_copy;
print $balances[0] + $balances[1] + $balances[2] . "\n";
