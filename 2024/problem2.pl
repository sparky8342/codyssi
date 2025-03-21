#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_2_input" or die "$!";
chomp( my @sensors = <$fh> );
close $fh;

@sensors = map { $_ eq "TRUE" ? 1 : 0 } @sensors;

# part 1
my $sum = 0;
for ( my $i = 0 ; $i < $#sensors ; $i++ ) {
    if ( $sensors[$i] ) {
        $sum += $i + 1;
    }
}
print "$sum\n";

# part 2 and 3
sub process_sensors {
    my @sensors = @_;
    my @new_sensors;

    my $and = 1;
    for ( my $i = 0 ; $i < $#sensors ; $i += 2 ) {
        my $out = 0;
        if ( $and && $sensors[$i] && $sensors[ $i + 1 ] ) {
            $out = 1;
        }
        elsif ( !$and && ( $sensors[$i] || $sensors[ $i + 1 ] ) ) {
            $out = 1;
        }
        $and = $and == 1 ? 0 : 1;
        push @new_sensors, $out;
    }
    return @new_sensors;
}

my $true  = 0;
my $part2 = 0;
map { $true += $_ } @sensors;
@sensors = process_sensors(@sensors);
map { $true  += $_ } @sensors;
map { $part2 += $_ } @sensors;
print "$part2\n";

# part 3
while ( $#sensors > 0 ) {
    @sensors = process_sensors(@sensors);
    map { $true += $_ } @sensors;
}

print "$true\n";
