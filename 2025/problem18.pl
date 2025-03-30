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

# parts 2 and 3
my $part2_cost = 30;
my $max_cost   = 300;

my @dp = ( { quality => 0, materials => 0 } ) x ( $max_cost + 1 );
for ( my $i = 0 ; $i < scalar @items ; $i++ ) {
    $dp[ $items[$i]->{cost} ] = {
        quality   => $items[$i]->{quality},
        items     => { $i => 1 },
        materials => $items[$i]->{materials},
    };
}

for ( my $i = 0 ; $i <= $max_cost ; $i++ ) {
    if ( !exists( $dp[$i]->{quality} ) ) {
        next;
    }
    for ( my $j = 0 ; $j < scalar @items ; $j++ ) {
        if ( exists( $dp[$i]->{items}->{$j} ) ) {
            next;
        }

        my $new_cost = $i + $items[$j]->{cost};

        if ( $new_cost > $max_cost ) {
            next;
        }

        my $existing_quality = $dp[$new_cost]->{quality};
        my $new_quality      = $dp[$i]->{quality} + $items[$j]->{quality};

        if ( $existing_quality > $new_quality ) {
            next;
        }

        my $existing_item_count = scalar keys %{ $dp[$new_cost]->{items} };
        my $new_item_count      = ( scalar keys %{ $dp[$i]->{items} } ) + 1;

        # not sure if this strategy will work with all inputs
        if (   $existing_quality == $new_quality
            && $existing_item_count < $new_item_count )
        {
            next;
        }

        $dp[$new_cost] = {
            quality   => $dp[$i]->{quality} + $items[$j]->{quality},
            items     => { ( %{ $dp[$i]->{items} }, ( $j => 1 ) ) },
            materials => $dp[$i]->{materials} + $items[$j]->{materials},
        };
    }
}

printf( "%d\n%d\n",
    $dp[$part2_cost]->{quality} * $dp[$part2_cost]->{materials},
    $dp[$max_cost]->{quality} * $dp[$max_cost]->{materials} );
