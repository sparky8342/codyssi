#!/usr/bin/perl
use strict;
use warnings;

use Data::Dumper;

#XX1XX
#X526X
#XX3XX
#XX4XX

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
    my ( $faces, $current_face, $current_dirs, $rotation ) = @_;

    my $letter_dir = $current_dirs->{$rotation};
    my $dir_change;
    ( $current_face, $dir_change ) = @{ $graph{$current_face}->{$letter_dir} };

    if ( $dir_change eq 'l' ) {
        $current_dirs = {
            'U' => $current_dirs->{'R'},
            'L' => $current_dirs->{'U'},
            'R' => $current_dirs->{'D'},
            'D' => $current_dirs->{'L'},
        };
    }
    elsif ( $dir_change eq 'r' ) {
        $current_dirs = {
            'U' => $current_dirs->{'L'},
            'L' => $current_dirs->{'D'},
            'R' => $current_dirs->{'U'},
            'D' => $current_dirs->{'R'},
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

my $size = 80;

open my $fh, "<", "inputs/view_problem_20_input" or die "$!";

#open my $fh, "<", "test2.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @turns = split //, $lines[ scalar @lines - 1 ];

my @faces;
for ( 1 .. 6 ) {
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
for ( 1 .. 6 ) {
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
        $absorptions[$current_face] += $size * $size * $1;
    }
    elsif ( $line =~ /^ROW (\d+) - VALUE (\d+)$/ ) {
        $absorptions[$current_face] += $size * $2;
    }
    elsif ( $line =~ /^COL (\d+) - VALUE (\d+)$/ ) {
        $absorptions[$current_face] += $size * $2;
    }

    if ( $i < scalar @turns ) {
        ( $current_face, $current_dirs ) =
          rotate( \@faces, $current_face, $current_dirs, $turns[$i] );
    }
}

@absorptions = sort { $b <=> $a } @absorptions;
printf( "%d\n", $absorptions[0] * $absorptions[1] );
