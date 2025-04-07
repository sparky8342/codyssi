#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

use constant XMIN => 0;
use constant XMAX => 9;
use constant YMIN => 0;
use constant YMAX => 14;
use constant ZMIN => 0;
use constant ZMAX => 59;
use constant AMIN => -1;
use constant AMAX => 1;

use constant XRANGE => 10;
use constant YRANGE => 15;
use constant ZRANGE => 60;
use constant ARANGE => 3;

#use constant XMIN => 0;
#use constant XMAX => 2;
#use constant YMIN => 0;
#use constant YMAX => 2;
#use constant ZMIN => 0;
#use constant ZMAX => 4;
#use constant AMIN => -1;
#use constant AMAX => 1;

#use constant XRANGE => 3;
#use constant YRANGE => 3;
#use constant ZRANGE => 5;
#use constant ARANGE => 3;

sub next_position {
    my ( $pos, $adj, $min, $max, $range ) = @_;
    $pos += $adj;
    if ( $pos < $min ) {
        $pos = $max;
    }
    elsif ( $pos > $max ) {
        $pos = $min;
    }
    return $pos;
}

sub next_debris {
    my ($debris) = @_;
    my @next;
    foreach my $piece (@$debris) {
        my $next_piece = {
            x => next_position( $piece->{x}, $piece->{vx}, XMIN, XMAX, XRANGE ),
            y => next_position( $piece->{y}, $piece->{vy}, YMIN, YMAX, YRANGE ),
            z => next_position( $piece->{z}, $piece->{vz}, ZMIN, ZMAX, ZRANGE ),
            a => next_position( $piece->{a}, $piece->{va}, AMIN, AMAX, ARANGE ),
            vx => $piece->{vx},
            vy => $piece->{vy},
            vz => $piece->{vz},
            va => $piece->{va},
        };
        push @next, $next_piece;
    }
    return \@next;
}

sub piece_key {
    my ($piece) = @_;
    return sprintf( "%d_%d_%d_%d_%d",
        $piece->{time}, $piece->{x}, $piece->{y}, $piece->{z}, $piece->{a} );
}

sub ship_neighbours {
    my ($ship) = @_;
    my @n = ( { %$ship, ( time => $ship->{time} + 1 ) } );
    if ( $ship->{x} < XMAX ) {
        push @n, { %$ship, ( time => $ship->{time} + 1, x => $ship->{x} + 1 ) };
    }
    if ( $ship->{x} > XMIN ) {
        push @n, { %$ship, ( time => $ship->{time} + 1, x => $ship->{x} - 1 ) };
    }
    if ( $ship->{y} < YMAX ) {
        push @n, { %$ship, ( time => $ship->{time} + 1, y => $ship->{y} + 1 ) };
    }
    if ( $ship->{y} > YMIN ) {
        push @n, { %$ship, ( time => $ship->{time} + 1, y => $ship->{y} - 1 ) };
    }
    if ( $ship->{z} < ZMAX ) {
        push @n, { %$ship, ( time => $ship->{time} + 1, z => $ship->{z} + 1 ) };
    }
    if ( $ship->{z} > ZMIN ) {
        push @n, { %$ship, ( time => $ship->{time} + 1, z => $ship->{z} - 1 ) };
    }
    return \@n;
}

open my $fh, "<", "inputs/view_problem_22_input" or die "$!";

#open my $fh, "<", "test2.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @rules;
foreach my $line (@lines) {
    $line =~
/^RULE (\d): (\d+)x\+(\d+)y\+(\d+)z\+(\d+)a DIVIDE (\d+) HAS REMAINDER (\d+) \| DEBRIS VELOCITY \(([01-]{1,2}), ([01-]{1,2}), ([01-]{1,2}), ([01-]{1,2})\)$/;
    my $rule = {
        no        => $1,
        x         => $2,
        y         => $3,
        z         => $4,
        a         => $5,
        divide    => $6,
        remainder => $7,
        vx        => $8,
        vy        => $9,
        vz        => $10,
        va        => $11,
    };
    push @rules, $rule;
}

# part 1
my @debris;
for ( my $x = XMIN ; $x <= XMAX ; $x++ ) {
    for ( my $y = YMIN ; $y <= YMAX ; $y++ ) {
        for ( my $z = ZMIN ; $z <= ZMAX ; $z++ ) {
            for ( my $a = AMIN ; $a <= AMAX ; $a++ ) {
                for my $rule (@rules) {
                    my $n =
                      $x * $rule->{x} +
                      $y * $rule->{y} +
                      $z * $rule->{z} +
                      $a * $rule->{a};
                    my $rem = $n % $rule->{divide};
                    if ( $rem == $rule->{remainder} ) {
                        my $piece = {
                            x  => $x,
                            y  => $y,
                            z  => $z,
                            a  => $a,
                            vx => $rule->{vx},
                            vy => $rule->{vy},
                            vz => $rule->{vz},
                            va => $rule->{va},
                        };
                        push @debris, $piece;
                    }
                }
            }
        }
    }
}
print scalar @debris . "\n";

# part 2
my %spacetime;
my $d = \@debris;

for my $time ( 0 .. 300 ) {
    for my $piece (@$d) {
        $spacetime{$time}{ $piece->{x} }{ $piece->{y} }{ $piece->{z} }
          { $piece->{a} } = 1;
    }
    $d = next_debris($d);
}

my $start = { time => 0, x => 0,  y => 0,  z => 0, a => 0 };
my $end   = { x    => 9, y => 14, z => 59, a => 0 };

#my $end = { x => 2, y => 2, z => 4, a => 0};

my @queue   = ($start);
my %visited = ( piece_key($start) => 1 );

while ( scalar @queue ) {
    my $ship = shift @queue;

    if (   $ship->{x} == $end->{x}
        && $ship->{y} == $end->{y}
        && $ship->{z} == $end->{z}
        && $ship->{a} == $end->{a} )
    {
        print "$ship->{time}\n";
        last;
    }

    my $neighbours = ship_neighbours($ship);

    for my $n (@$neighbours) {
        if (
            ( $n->{x} == 0 && $n->{y} == 0 && $n->{z} == 0 && $n->{a} == 0 )
            || (
                !exists(
                    $spacetime{ $n->{time} }{ $n->{x} }{ $n->{y} }{ $n->{z} }
                      { $n->{a} }
                )
            )
          )
        {
            my $key = piece_key($n);
            if ( !exists( $visited{$key} ) ) {
                push @queue, $n;
                $visited{$key} = 1;
            }
        }
    }
}
