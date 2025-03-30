#!/usr/bin/perl
use strict;
use warnings;

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

# part 2
@items = sort { $a->{cost} <=> $b->{cost} } @items;

my @dp = ( {} ) x 31;
for ( my $i = 0 ; $i < scalar @items ; $i++ ) {
    $dp[ $items[$i]->{cost} ] = {
        quality   => $items[$i]->{quality},
        items     => { $i => 1 },
        materials => $items[$i]->{materials}
    };
}

for ( my $i = 0 ; $i <= 30 ; $i++ ) {
    if ( !exists( $dp[$i]->{quality} ) ) {
        next;
    }
    for ( my $j = 0 ; $j < scalar @items ; $j++ ) {
        if ( exists( $dp[$i]->{items}->{$j} ) ) {
            next;
        }
        my $new_cost = $i + $items[$j]->{cost};
        if ( $new_cost <= 30 ) {
            if ( !exists( $dp[$new_cost]->{quality} )
                || $dp[$new_cost]->{quality} <
                $dp[$i]->{quality} + $items[$j]->{quality} )
            {
                my %new_items = %{ $dp[$i]->{items} };
                $new_items{$j} = 1;
                $dp[$new_cost] = {
                    quality   => $dp[$i]->{quality} + $items[$j]->{quality},
                    items     => \%new_items,
                    materials => $dp[$i]->{materials} + $items[$j]->{materials}
                };
            }
        }
    }
}

print $dp[30]->{quality} * $dp[30]->{materials} . "\n";

