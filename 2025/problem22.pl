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

#use constant XMIN => 0;
#use constant XMAX => 2;
#use constant YMIN => 0;
#use constant YMAX => 2;
#use constant ZMIN => 0;
#use constant ZMAX => 4;
#use constant AMIN => -1;
#use constant AMAX => 1;

open my $fh, "<", "inputs/view_problem_22_input" or die "$!";

#open my $fh, "<", "test.txt" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

my @rules;
foreach my $line (@lines) {
    print "$line\n";
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
my $debris = 0;
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
                        $debris++;
                    }
                }
            }
        }
    }
}
print "$debris\n";
