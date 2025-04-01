#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max);
use Math::BigInt;

use Data::Dumper;

#XX1XX
#X526X
#XX3XX
#XX4XX

# TODO make faces start at 0

use constant MOD => 100;

my $size = 80;

#my $size = 3;

my %graph;

# n = nothing, l = rotate left, r = rotate right, f = flip 180
$graph{1} = {
    'A' => [ 4, "n" ],
    'B' => [ 6, "n" ],
    'C' => [ 2, "n" ],
    'D' => [ 5, "n" ],
};
$graph{2} = {
    'A' => [ 1, "n" ],
    'B' => [ 6, "r" ],
    'C' => [ 3, "n" ],
    'D' => [ 5, "l" ],
};
$graph{3} = {
    'A' => [ 2, "n" ],
    'B' => [ 6, "f" ],
    'C' => [ 4, "n" ],
    'D' => [ 5, "f" ],
};
$graph{4} = {
    'A' => [ 3, "n" ],
    'B' => [ 6, "l" ],
    'C' => [ 1, "n" ],
    'D' => [ 5, "r" ],
};
$graph{5} = {
    'A' => [ 4, "l" ],
    'B' => [ 1, "n" ],
    'C' => [ 2, "r" ],
    'D' => [ 3, "f" ],
};
$graph{6} = {
    'A' => [ 4, "r" ],
    'B' => [ 3, "f" ],
    'C' => [ 2, "l" ],
    'D' => [ 1, "n" ],
};

sub rotate {
    my ( $current_face, $current_dirs, $rotation ) = @_;

    my $letter_dir = $current_dirs->{$rotation};
    my $dir_change;
    ( $current_face, $dir_change ) = @{ $graph{$current_face}->{$letter_dir} };

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

sub update_row {
    my ( $faces, $current_face, $current_dirs, $r, $n ) = @_;

    my $up = $current_dirs->{'U'};
    $r--;

    if ( $up eq 'C' || $up eq 'B' ) {
        $r = $size - $r - 1;
    }

    if ( $up eq 'A' || $up eq 'C' ) {
        for ( my $col = 0 ; $col < $size ; $col++ ) {
            $faces->[$current_face][$r][$col] += $n;
            while ( $faces->[$current_face][$r][$col] > 100 ) {
                $faces->[$current_face][$r][$col] -= 100;
            }
        }
    }
    elsif ( $up eq 'B' || $up eq 'D' ) {
        for ( my $row = 0 ; $row < $size ; $row++ ) {
            $faces->[$current_face][$row][$r] += $n;
            while ( $faces->[$current_face][$row][$r] > 100 ) {
                $faces->[$current_face][$row][$r] -= 100;
            }
        }
    }
}

sub update_col {
    my ( $faces, $current_face, $current_dirs, $c, $n ) = @_;

    my $up = $current_dirs->{'U'};
    $c--;

    if ( $up eq 'C' || $up eq 'D' ) {
        $c = $size - $c - 1;
    }

    if ( $up eq 'A' || $up eq 'C' ) {
        for ( my $row = 0 ; $row < $size ; $row++ ) {
            $faces->[$current_face][$row][$c] += $n;
            while ( $faces->[$current_face][$row][$c] > 100 ) {
                $faces->[$current_face][$row][$c] -= 100;
            }
        }
    }
    elsif ( $up eq 'B' || $up eq 'D' ) {
        for ( my $col = 0 ; $col < $size ; $col++ ) {
            $faces->[$current_face][$c][$col] += $n;
            while ( $faces->[$current_face][$c][$col] > 100 ) {
                $faces->[$current_face][$c][$col] -= 100;
            }
        }
    }
}

sub max_row_col {
    my ($face) = @_;

    my $max = 0;
    for ( my $i = 0 ; $i < $size ; $i++ ) {
        my $r = 0;
        my $c = 0;
        for ( my $j = 0 ; $j < $size ; $j++ ) {
            $r += $face->[$i][$j];
            $c += $face->[$j][$i];
        }
        $max = max( $max, $r );
        $max = max( $max, $c );
    }

    return $max;
}

open my $fh, "<", "inputs/view_problem_20_input" or die "$!";

#open my $fh, "<", "test2.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @turns = split //, $lines[ scalar @lines - 1 ];

my @faces;
for ( 1 .. 7 ) {
    my @face;
    for ( 1 .. $size ) {
        my @row;
        for ( 1 .. $size ) {
            push @row, 1;
        }
        push @face, \@row;
    }
    push @faces, \@face;
}

my @absorptions;
for ( 1 .. 7 ) {
    push @absorptions, 0;
}

my $current_face = 1;
my $current_dirs = { 'U' => 'A', 'L' => 'D', 'R' => 'B', 'D' => 'C' };

for ( my $i = 0 ; $i < scalar @lines ; $i++ ) {
    my $line = $lines[$i];
    if ( $line eq '' ) {
        last;
    }
    if ( $line =~ /^FACE - VALUE (\d+)$/ ) {
        my $n = $1;
        $absorptions[$current_face] += $size * $size * $n;
        for ( my $y = 0 ; $y < $size ; $y++ ) {
            for ( my $x = 0 ; $x < $size ; $x++ ) {
                $faces[$current_face][$y][$x] += $n;
                while ( $faces[$current_face][$y][$x] > 100 ) {
                    $faces[$current_face][$y][$x] -= 100;
                }

            }
        }
    }
    elsif ( $line =~ /^ROW (\d+) - VALUE (\d+)$/ ) {
        my ( $row, $n ) = ( $1, $2 );
        $absorptions[$current_face] += $size * $n;
        update_row( \@faces, $current_face, $current_dirs, $row, $n );
    }
    elsif ( $line =~ /^COL (\d+) - VALUE (\d+)$/ ) {
        my ( $col, $n ) = ( $1, $2 );
        $absorptions[$current_face] += $size * $2;
        update_col( \@faces, $current_face, $current_dirs, $col, $n );
    }

    if ( $i < scalar @turns ) {

        # probably don't need to reverse dirs here
        my $rot;
        if ( $turns[$i] eq 'U' ) {
            $rot = 'D';
        }
        elsif ( $turns[$i] eq 'D' ) {
            $rot = 'U';
        }
        elsif ( $turns[$i] eq 'L' ) {
            $rot = 'R';
        }
        elsif ( $turns[$i] eq 'R' ) {
            $rot = 'L';
        }

        ( $current_face, $current_dirs ) =
          rotate( $current_face, $current_dirs, $rot );
    }

}

# part 1
@absorptions = sort { $b <=> $a } @absorptions;
printf( "%d\n", $absorptions[0] * $absorptions[1] );

# part 2
my $product = Math::BigInt->new(1);
for ( my $i = 1 ; $i <= 6 ; $i++ ) {
    my $val = Math::BigInt->new( max_row_col( $faces[$i] ) );
    $product->bmul($val);
    print "$val\n";
}

print $product . "\n";
