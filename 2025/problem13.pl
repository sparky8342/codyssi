#!/usr/bin/perl
package Person;
use strict;
use warnings;

sub new {
    my ( $class, $balance ) = @_;
    my $self = {
        balance => $balance,
        debts   => [],
    };
    bless $self, $class;
    return $self;
}

sub balance {
    my ($self) = @_;
    return $self->{balance};
}

sub add {
    my ( $self, $amount ) = @_;
    $self->{balance} += $amount;
    return $self->resolve_debts();
}

sub subtract {
    my ( $self, $amount ) = @_;
    $self->{balance} -= $amount;
}

sub add_debt {
    my ( $self, $debt ) = @_;
    push @{ $self->{debts} }, $debt;
}

sub resolve_debts {
    my ($self) = @_;
    my @to_pay;
    while ( scalar @{ $self->{debts} } && $self->balance() > 0 ) {
        if ( $self->{debts}->[0]->amount() < $self->balance() ) {
            $self->subtract( $self->{debts}->[0]->amount() );
            push @to_pay, shift @{ $self->{debts} };
        }
        else {
            push @to_pay, Debt->new($self->{debts}->[0]->name(), $self->balance());
            $self->{debts}->[0]->subtract($self->balance());
            $self->subtract( $self->balance() );
        }
    }
    return @to_pay;
}

package Debt;
use strict;
use warnings;

sub new {
    my ( $class, $name, $amount ) = @_;
    my $self = {
        name => $name,
        amount => $amount,
    };
    bless $self, $class;
    return $self;
}

sub name {
	my ($self) = @_;
	return $self->{name};
}

sub amount {
	my ($self) = @_;
	return $self->{amount};
}

sub subtract {
	my ($self, $amount) = @_;
	$self->{amount} -= $amount;
}

package main;
use strict;
use warnings;
use Storable qw(dclone);

sub run_transactions {
    my ( $people, $transactions, $mode ) = @_;
    $people = dclone($people);

    for my $transaction (@$transactions) {
        my ( $from_name, $to_name, $amount ) = @$transaction;

        my $from = $people->{$from_name};
        my $to   = $people->{$to_name};

        if ( $mode == 1 && $from->balance() < $amount ) {
            $amount = $from->balance();
        }

        if ( $mode == 2 && $from->balance() < $amount ) {
	    my $debt = Debt->new($to_name, $amount - $from->balance());
            $from->add_debt($debt);
            $amount = $from->balance();
        }

        $from->subtract($amount);
        my @pay = $to->add($amount);
	while (scalar @pay) {
		my $debt = shift @pay;
		push @pay, $people->{$debt->name()}->add($debt->amount());
	}
    }

    my @balances;
    for my $person ( values %$people ) {
        push @balances, $person->balance();
    }

    @balances = sort { $b <=> $a } @balances;
    return $balances[0] + $balances[1] + $balances[2];
}

open my $fh, "<", "inputs/view_problem_13_input" or die "$!";
chomp( my @lines = <$fh> );
close $fh;

# parse data
my %people;
my $i;
for ( $i = 0 ; $i < scalar @lines ; $i++ ) {
    if ( $lines[$i] =~ /^([A-Za-z-]+) HAS (\d+)$/ ) {
        $people{$1} = Person->new($2);
    }
    else {
        last;
    }
}
$i++;
my @transactions;
for ( ; $i < scalar @lines ; $i++ ) {
    $lines[$i] =~ /^FROM ([A-Za-z-]+) TO ([A-Za-z-]+) AMT (\d+)$/;
    push @transactions, [ $1, $2, $3 ];
}

# part 1
my $top_three = run_transactions( \%people, \@transactions, 0 );
print "$top_three\n";

# part 2
$top_three = run_transactions( \%people, \@transactions, 1 );
print "$top_three\n";

# part 3
$top_three = run_transactions( \%people, \@transactions, 2 );
print "$top_three\n";
