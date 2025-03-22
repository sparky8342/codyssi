#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_6_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# a = add
# b = multiply
# c = power
my ($function_a) = $lines[0] =~ /(\d+)/;
my ($function_b) = $lines[1] =~ /(\d+)/;
my ($function_c) = $lines[2] =~ /(\d+)/;

my @nums = @lines[ 4 .. scalar @lines - 1 ];
@nums = sort { $a <=> $b } @nums;

# part 1
my $median = $nums[ scalar @nums / 2 ];
my $price  = $median**$function_c * $function_b + $function_a;
print "$price\n";

# part 2
my $quality = 0;
map { $quality += $_ % 2 == 0 ? $_ : 0 } @nums;
$price = $quality**$function_c * $function_b + $function_a;
print "$price\n";
