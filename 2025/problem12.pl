#!/usr/bin/perl
use strict;
use warnings;

open my $fh, "<", "inputs/view_problem_12_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# part 1
my $ab = 0;
for my $line (@lines) {
    for my $char ( split //, $line ) {
        if (   ( $char ge 'a' && $char le 'z' )
            || ( $char ge 'A' && $char le 'Z' ) )
        {
            $ab++;
        }
    }
}
print "$ab\n";

# part 2
my $count = 0;
for my $line (@lines) {
    my $copy = $line;
    1 while $copy =~ s/\d\D|\D\d//g;
    $count += length($copy);
}
print "$count\n";

# part 3
$count = 0;
for my $line (@lines) {
    my $copy = $line;
    1 while $copy =~ s/\d[a-zA-Z]|[a-zA-Z]\d//g;
    $count += length($copy);
}
print "$count\n";
