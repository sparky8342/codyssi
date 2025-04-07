#!/usr/bin/perl
use strict;
use warnings;

use constant {
    XMIN => 0,
    XMAX => 9,
    YMIN => 0,
    YMAX => 14,
    ZMIN => 0,
    ZMAX => 59,
    AMIN => -1,
    AMAX => 1,
};

sub next_position {
    my ( $pos, $adj, $min, $max ) = @_;
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
            x  => next_position( $piece->{x}, $piece->{vx}, XMIN, XMAX ),
            y  => next_position( $piece->{y}, $piece->{vy}, YMIN, YMAX ),
            z  => next_position( $piece->{z}, $piece->{vz}, ZMIN, ZMAX ),
            a  => next_position( $piece->{a}, $piece->{va}, AMIN, AMAX ),
            vx => $piece->{vx},
            vy => $piece->{vy},
            vz => $piece->{vz},
            va => $piece->{va},
        };
        push @next, $next_piece;
    }
    return \@next;
}

sub ship_key {
    my ($ship) = @_;
    return sprintf(
        "%d_%d_%d_%d_%d_%d",
        $ship->{time}, $ship->{x}, $ship->{y},
        $ship->{z},    $ship->{a}, $ship->{hp}
    );
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

sub bfs {
    my ( $spacetime, $hp ) = @_;

    my $start = { time => 0, x => 0,  y => 0,  z => 0, a => 0, hp => $hp };
    my $end   = { x    => 9, y => 14, z => 59, a => 0 };

    my @queue   = ($start);
    my %visited = ( ship_key($start) => 1 );

    while ( scalar @queue ) {
        my $ship = shift @queue;

        if ( $ship->{hp} < 0 ) {
            next;
        }

        if (   $ship->{x} == $end->{x}
            && $ship->{y} == $end->{y}
            && $ship->{z} == $end->{z}
            && $ship->{a} == $end->{a} )
        {
            return $ship->{time};
        }

        my $neighbours = ship_neighbours($ship);

        for my $n (@$neighbours) {
            my $key = ship_key($n);
            if ( exists( $visited{$key} ) ) {
                next;
            }

            my $damage = 0;
            if (
                exists(
                    $spacetime->{ $n->{time} }{ $n->{x} }{ $n->{y} }{ $n->{z} }
                      { $n->{a} }
                )
              )
            {
                $damage =
                  $spacetime->{ $n->{time} }{ $n->{x} }{ $n->{y} }{ $n->{z} }
                  { $n->{a} };
            }

            $n->{hp} -= $damage;

            push @queue, $n;
            $visited{$key} = 1;
        }
    }
}

open my $fh, "<", "inputs/view_problem_22_input" or die "$!";
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
my $debris;
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
                        push @$debris, $piece;
                    }
                }
            }
        }
    }
}
print scalar @$debris . "\n";

# part 2
my %spacetime;

for my $time ( 0 .. 300 ) {
    for my $piece (@$debris) {
        if (   $piece->{x} == 0
            && $piece->{y} == 0
            && $piece->{z} == 0
            && $piece->{a} == 0 )
        {
            next;
        }
        $spacetime{$time}{ $piece->{x} }{ $piece->{y} }{ $piece->{z} }
          { $piece->{a} }++;
    }
    $debris = next_debris($debris);
}

my $time = bfs( \%spacetime, 0 );
print "$time\n";

# part 3
$time = bfs( \%spacetime, 3 );
print "$time\n";
