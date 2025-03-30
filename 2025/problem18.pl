#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

open my $fh, "<", "inputs/view_problem_18_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @items;
for my $line (@lines) {
    $line =~
      /^\d+ (\w+) \| Quality : (\d+), Cost : (\d+), Unique Materials : (\d+)$/;
    push @items, { code => $1, quality => $2, cost => $3, materials => $4 };
}

# part 1
@items =
  sort { $b->{quality} <=> $a->{quality} || $b->{cost} <=> $a->{cost} } @items;
my $total = 0;
for ( my $i = 0 ; $i < 5 ; $i++ ) {
    $total += $items[$i]->{materials};
}
print "$total\n";
