#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_13_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# part 1
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
for ( ; $i < scalar @lines ; $i++ ) {
    $lines[$i] =~ /^FROM ([A-Za-z-]+) TO ([A-Za-z-]+) AMT (\d+)$/;
    $people{$1} -= $3;
    $people{$2} += $3;
}

my @balances = sort { $b <=> $a } values %people;
print $balances[0] + $balances[1] + $balances[2] . "\n";
