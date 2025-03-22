#!/usr/bin/perl
use strict;
use warnings;

sub line_units {
    my ($line) = @_;
    my $units = 0;
    for my $char ( split //, $line ) {
        if ( $char eq '0' ) {
            next;
        }
        elsif ( $char ge '1' && $char le '9' ) {
            $units += $char;
        }
        else {
            $units += ord($char) - 64;
        }
    }
    return $units;
}

sub lossy {
    my ($line) = @_;
    my $keep   = int( length($line) / 10 );
    my $num    = length($line) - $keep * 2;
    return
        substr( $line, 0, $keep )
      . $num
      . substr( $line, length($line) - $keep, $keep );
}

sub rle {
    my ($line) = @_;

    my @chars = split //, $line;
    push @chars, '@';

    my $amount = 1;
    my $char   = $chars[0];

    my @encoded;

    for ( my $i = 1 ; $i < scalar @chars ; $i++ ) {
        if ( $chars[$i] ne $char ) {
            push @encoded, $amount;
            push @encoded, $char;
            $char   = $chars[$i];
            $amount = 1;
        }
        else {
            $amount++;
        }
    }

    return join( '', @encoded );
}

open my $fh, "<", "inputs/view_problem_8_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# part 1
my $units = 0;
for my $line (@lines) {
    $units += line_units($line);
}
print "$units\n";

# part 2
$units = 0;
for my $line (@lines) {
    $units += line_units( lossy($line) );
}
print "$units\n";

# part 3
$units = 0;
for my $line (@lines) {
    $units += line_units( rle($line) );
}
print "$units\n";
