#!/usr/bin/perl
use strict;
use warnings;
use lib './lib';
use Tokenizer qw(%TOKEN_TYPE create_token);

while (my $input = <>) {
    chomp $input;
    my $tokenizer = Tokenizer->new($input);

    while (1) {
        my $token = $tokenizer->get_next_token();
        print "Type: $token->{type}, Literal: $token->{literal}\n";
        if ($token->{type} eq $TOKEN_TYPE{Eof}) {
            last;
        }
    }
}

print "suck it chat\n";

