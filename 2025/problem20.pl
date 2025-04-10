#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max);
use Math::BigInt;
use Storable qw(dclone);

use constant SIZE => 80;

# move from face id in one of four directions (A, B, C or D)
# the value is the new face and any rotation to be made
# (of the viewer)
#
# n = nothing, l = rotate left, r = rotate right, f = flip 180
my %move_rotation = (
    0 => {
        'A' => [ 3, "n" ],
        'B' => [ 5, "n" ],
        'C' => [ 1, "n" ],
        'D' => [ 4, "n" ],
    },
    1 => {
        'A' => [ 0, "n" ],
        'B' => [ 5, "r" ],
        'C' => [ 2, "n" ],
        'D' => [ 4, "l" ],
    },
    2 => {
        'A' => [ 1, "n" ],
        'B' => [ 5, "f" ],
        'C' => [ 3, "n" ],
        'D' => [ 4, "f" ],
    },
    3 => {
        'A' => [ 2, "n" ],
        'B' => [ 5, "l" ],
        'C' => [ 0, "n" ],
        'D' => [ 4, "r" ],
    },
    4 => {
        'A' => [ 3, "l" ],
        'B' => [ 0, "n" ],
        'C' => [ 1, "r" ],
        'D' => [ 2, "f" ],
    },
    5 => {
        'A' => [ 3, "r" ],
        'B' => [ 2, "f" ],
        'C' => [ 1, "l" ],
        'D' => [ 0, "n" ],
    }
);

sub process_commands {
    my ( $faces, $lines, $turns, $wrap_around ) = @_;

    my @absorptions;
    for ( 1 .. 6 ) {
        push @absorptions, 0;
    }

    my $current_face = 0;
    my $current_dirs = { 'U' => 'A', 'L' => 'D', 'R' => 'B', 'D' => 'C' };

    for ( my $i = 0 ; $i < scalar @$lines ; $i++ ) {
        my $line = $lines->[$i];
        if ( $line =~ /^FACE - VALUE (\d+)$/ ) {
            my $n = $1;
            $absorptions[$current_face] += SIZE * SIZE * $n;
            update_all( $faces->[$current_face], $n );
        }
        elsif ( $line =~ /^ROW (\d+) - VALUE (\d+)$/ ) {
            my ( $row, $n ) = ( $1, $2 );
            $absorptions[$current_face] += SIZE * $n;
            update_row( $faces->[$current_face], $current_dirs, $row, $n );
            if ($wrap_around) {
                my $dir = 'R';

                for ( 1 .. 3 ) {
                    ( $current_face, $current_dirs ) =
                      rotate( $current_face, $current_dirs, $dir );
                    update_row( $faces->[$current_face],
                        $current_dirs, $row, $n );
                }
                ( $current_face, $current_dirs ) =
                  rotate( $current_face, $current_dirs, $dir );
            }
        }
        elsif ( $line =~ /^COL (\d+) - VALUE (\d+)$/ ) {
            my ( $col, $n ) = ( $1, $2 );
            $absorptions[$current_face] += SIZE * $n;
            update_col( $faces->[$current_face], $current_dirs, $col, $n );
            if ($wrap_around) {
                my $dir = 'U';

                for ( 1 .. 3 ) {
                    ( $current_face, $current_dirs ) =
                      rotate( $current_face, $current_dirs, $dir );
                    update_col( $faces->[$current_face],
                        $current_dirs, $col, $n );
                }
                ( $current_face, $current_dirs ) =
                  rotate( $current_face, $current_dirs, $dir );
            }
        }

        if ( $i < scalar @$turns ) {
            ( $current_face, $current_dirs ) =
              rotate( $current_face, $current_dirs, $turns->[$i] );
        }
    }

    @absorptions = sort { $b <=> $a } @absorptions;

    my $product = Math::BigInt->new(1);
    for ( my $i = 0 ; $i < 6 ; $i++ ) {
        my $val = Math::BigInt->new( max_row_col( $faces->[$i] ) );
        $product->bmul($val);
    }

    return ( $absorptions[0] * $absorptions[1], $product );
}

sub rotate {
    my ( $current_face, $current_dirs, $rotation ) = @_;

    my $letter_dir = $current_dirs->{$rotation};
    my $dir_change;
    ( $current_face, $dir_change ) =
      @{ $move_rotation{$current_face}->{$letter_dir} };

    if ( $dir_change eq 'l' ) {
        $current_dirs = {
            'U' => $current_dirs->{'R'},
            'R' => $current_dirs->{'D'},
            'D' => $current_dirs->{'L'},
            'L' => $current_dirs->{'U'},
        };
    }
    elsif ( $dir_change eq 'r' ) {
        $current_dirs = {
            'U' => $current_dirs->{'L'},
            'R' => $current_dirs->{'U'},
            'D' => $current_dirs->{'R'},
            'L' => $current_dirs->{'D'},
        };
    }
    elsif ( $dir_change eq 'f' ) {
        $current_dirs = {
            'U' => $current_dirs->{'D'},
            'L' => $current_dirs->{'R'},
            'R' => $current_dirs->{'L'},
            'D' => $current_dirs->{'U'},
        };
    }

    return ( $current_face, $current_dirs );
}

sub add {
    my ( $num, $n ) = @_;
    $num += $n;
    while ( $num > 100 ) {
        $num -= 100;
    }
    return $num;
}

sub update_all {
    my ( $face, $n ) = @_;
    for ( my $y = 0 ; $y < SIZE ; $y++ ) {
        for ( my $x = 0 ; $x < SIZE ; $x++ ) {
            $face->[$y][$x] = add( $face->[$y][$x], $n );
        }
    }
}

sub update_row {
    my ( $face, $current_dirs, $r, $n ) = @_;

    my $up = $current_dirs->{'U'};
    $r--;

    if ( $up eq 'C' || $up eq 'B' ) {
        $r = SIZE - $r - 1;
    }

    if ( $up eq 'A' || $up eq 'C' ) {
        for ( my $col = 0 ; $col < SIZE ; $col++ ) {
            $face->[$r][$col] = add( $face->[$r][$col], $n );
        }
    }
    elsif ( $up eq 'B' || $up eq 'D' ) {
        for ( my $row = 0 ; $row < SIZE ; $row++ ) {
            $face->[$row][$r] = add( $face->[$row][$r], $n );
        }
    }
}

sub update_col {
    my ( $face, $current_dirs, $c, $n ) = @_;

    my $up = $current_dirs->{'U'};
    $c--;

    if ( $up eq 'C' || $up eq 'D' ) {
        $c = SIZE - $c - 1;
    }

    if ( $up eq 'A' || $up eq 'C' ) {
        for ( my $row = 0 ; $row < SIZE ; $row++ ) {
            $face->[$row][$c] = add( $face->[$row][$c], $n );
        }
    }
    elsif ( $up eq 'B' || $up eq 'D' ) {
        for ( my $col = 0 ; $col < SIZE ; $col++ ) {
            $face->[$c][$col] = add( $face->[$c][$col], $n );
        }
    }
}

sub max_row_col {
    my ($face) = @_;

    my $max = 0;
    for ( my $i = 0 ; $i < SIZE ; $i++ ) {
        my $r = 0;
        my $c = 0;
        for ( my $j = 0 ; $j < SIZE ; $j++ ) {
            $r += $face->[$i][$j];
            $c += $face->[$j][$i];
        }
        $max = max( $max, $r );
        $max = max( $max, $c );
    }

    return $max;
}

open my $fh, "<", "inputs/view_problem_20_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @turns = split //, pop @lines;
pop @lines;

my @faces;
for ( 1 .. 6 ) {
    my @face;
    for ( 1 .. SIZE ) {
        my @row = (1) x SIZE;
        push @face, \@row;
    }
    push @faces, \@face;
}

# parts 1 and 2
my ( $absorption_product, $product ) =
  process_commands( dclone( \@faces ), \@lines, \@turns );
print "$absorption_product\n$product\n";

# part 3
( undef, $product ) =
  process_commands( dclone( \@faces ), \@lines, \@turns, 1 );
print "$product\n";

