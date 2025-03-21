#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_1_input" or die "$!";
chomp( my @prices = <$fh> );
close $fh;

# part 1
my $sum = 0;
map { $sum += $_ } @prices;
print "$sum\n";

# part 2
my @sorted_prices = sort { $b <=> $a } @prices;
@sorted_prices = @sorted_prices[ 20 .. $#sorted_prices ];
$sum           = 0;
map { $sum += $_ } @sorted_prices;
print "$sum\n";

# part 3
$sum = 0;
my $m = 1;
map { $sum += $_ * $m; $m *= -1 } @prices;
print "$sum\n";
