#!/usr/bin/perl
use strict;
use warnings;
use List::Util qw(max);
use Storable   qw(dclone);

use Data::Dumper;

use constant MOD => 1073741824;
my $size;

sub shift_row {
    my ( $grid, $row, $amount ) = @_;
    for ( 1 .. $amount ) {
        unshift @{ $grid->[$row] }, pop @{ $grid->[$row] };
    }
}

sub shift_col {
    my ( $grid, $col, $amount ) = @_;

    my @arr;
    for ( my $y = 0 ; $y < $size ; $y++ ) {
        push @arr, $grid->[$y]->[$col];
    }

    for ( 1 .. $amount ) {
        unshift @arr, pop @arr;
    }

    for ( my $y = 0 ; $y < scalar $size ; $y++ ) {
        $grid->[$y]->[$col] = $arr[$y];
    }
}

sub apply_op {
    my ( $op, $value, $amount ) = @_;
    if ( $op eq 'ADD' ) {
        return ( $value + $amount ) % MOD;
    }
    elsif ( $op eq 'SUB' ) {
        return ( $value - $amount ) % MOD;
    }
    elsif ( $op eq 'MULTIPLY' ) {
        return ( $value * $amount ) % MOD;
    }
}

sub math_op_row {
    my ( $grid, $op, $row, $amount ) = @_;
    for ( my $x = 0 ; $x < $size ; $x++ ) {
        $grid->[$row]->[$x] = apply_op( $op, $grid->[$row]->[$x], $amount );
    }
}

sub math_op_col {
    my ( $grid, $op, $col, $amount ) = @_;
    for ( my $y = 0 ; $y < $size ; $y++ ) {
        $grid->[$y]->[$col] = apply_op( $op, $grid->[$y]->[$col], $amount );
    }
}

sub math_op_all {
    my ( $grid, $op, $amount ) = @_;
    for ( my $y = 0 ; $y < $size ; $y++ ) {
        for ( my $x = 0 ; $x < $size ; $x++ ) {
            $grid->[$y]->[$x] = apply_op( $op, $grid->[$y]->[$x], $amount );
        }
    }
}

sub execute_ins {
    my ( $g, $line ) = @_;

    my @ins = split /\s/, $line;
    my $op  = $ins[0];

    if ( $op eq 'SHIFT' ) {
        my $rowcol = $ins[1];
        my $value  = $ins[2] - 1;
        my $amount = $ins[4];
        if ( $rowcol eq 'ROW' ) {
            shift_row( $g, $value, $amount );
        }
        elsif ( $rowcol eq 'COL' ) {
            shift_col( $g, $value, $amount );
        }
    }
    elsif ( $op eq 'ADD' || $op eq 'SUB' || $op eq 'MULTIPLY' ) {
        my $which  = $ins[2];
        my $amount = $ins[1];
        if ( $which eq 'ROW' ) {
            my $value = $ins[3] - 1;
            math_op_row( $g, $op, $value, $amount );
        }
        elsif ( $which eq 'COL' ) {
            my $value = $ins[3] - 1;
            math_op_col( $g, $op, $value, $amount );
        }
        elsif ( $which eq 'ALL' ) {
            math_op_all( $g, $op, $amount );
        }
    }
}

sub max_row_col {
    my ($g) = @_;
    my $max = 0;
    for ( my $i = 0 ; $i < $size ; $i++ ) {
        my $r = 0;
        my $c = 0;
        for ( my $j = 0 ; $j < $size ; $j++ ) {
            $r += $g->[$i][$j];
            $c += $g->[$j][$i];
        }
        $max = max( $max, $r );
        $max = max( $max, $c );
    }
    return $max;
}

open my $fh, "<", "inputs/view_problem_16_input" or die "$!";

#open my $fh, "<", "test.txt" or die "$!";
my $data = do { local $/; <$fh> };
close $fh;

my @parts = split /\n\n/, $data;

my @grid;
foreach my $line ( split /\n/, $parts[0] ) {
    push @grid, [ split /\s/, $line ];
}

$size = scalar @grid;
my @instructions = split /\n/, $parts[1];

#ADD 60 ROW 25
#SUB 79 COL 1
#SHIFT ROW 30 BY 19
#MULTIPLY 4 COL 19
#SHIFT COL 29 BY 28
#ADD 6 ROW 6
#SHIFT COL 26 BY 5
#SUB 98 ROW 17
#MULTIPLY 2 ROW 1
#SHIFT ROW 27 BY 19

# part 1
my $g = dclone( \@grid );
foreach my $line (@instructions) {
    execute_ins( $g, $line );
}
print max_row_col($g) . "\n";

# part 2
$g = dclone( \@grid );
my $ins;
foreach my $flow ( split /\n/, $parts[2] ) {
    if ( $flow eq 'TAKE' ) {
        $ins = shift @instructions;
    }
    elsif ( $flow eq 'CYCLE' ) {
        push @instructions, $ins;
    }
    elsif ( $flow eq 'ACT' ) {
        execute_ins( $g, $ins );
    }
}
print max_row_col($g) . "\n";
