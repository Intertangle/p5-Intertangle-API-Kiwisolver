#!/usr/bin/env perl

use Test::Most tests => 1;

use Renard::Incunabula::Common::Setup;
use Renard::API::Kiwisolver;

fun chain($solver, $n) {
	die unless $n >= 1;
	my @vars;
	push @vars, Renard::API::Kiwisolver::Variable->new("x_1");
	note "n = ${n}";
	note <<EOF;
We construct a long chain of required equality constraints
\( x_1 = x_2 = ... = x_n \).';
EOF
	for my $i (2..$n) {
		push @vars, Renard::API::Kiwisolver::Variable->new("x_${i}");
		$solver->addConstraint(
			( $vars[-2] == $vars[-1] )
			| Renard::API::Kiwisolver::Strength::REQUIRED
		);
	}
	note 'There is a weak stay on \( x_n \).';
	$solver->addEditVariable($vars[-1], Renard::API::Kiwisolver::Strength::WEAK );
	\@vars;
}

subtest "Chain benchmark" => fun() {
	my $solver = Renard::API::Kiwisolver::Solver->new;
	my $vars = chain($solver, 1000);

	is $vars->[-1]->value, 0, "@{[ $vars->[-1]->name ]} initially 0";

	note 'We then add a strong edit constraint to \( x_1 \).';
	$solver->addEditVariable($vars->[0], Renard::API::Kiwisolver::Strength::STRONG );

	note 'Change value of \( x_1 \) one time.';
	my $value = 42;
	$solver->suggestValue($vars->[0], $value);
	$solver->updateVariables;

	is $vars->[-1]->value, $value, "@{[ $vars->[-1] ]} changed to @{[ $vars->[0] ]}";
};

done_testing;
