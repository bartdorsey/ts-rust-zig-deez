#!/usr/bin/perl
use strict;
use warnings;
use Test::More;
use lib './lib';
use Tokenizer qw(%TOKEN_TYPE create_token);

# Tests for create_token
{
    my $token = create_token($TOKEN_TYPE{Int}, '5');
    is($token->{type}, $TOKEN_TYPE{Int}, 'Token type should be Int');
    is($token->{literal}, '5', 'Token literal should be 5');
}

# Tests for is_letter
{
    my $tokenizer = Tokenizer->new('');
    ok($tokenizer->is_letter('a'), 'a is a letter');
    ok($tokenizer->is_letter('Z'), 'Z is a letter');
    ok($tokenizer->is_letter('_'), '_ is a letter');
    ok(!$tokenizer->is_letter('1'), '1 is not a letter');
    ok(!$tokenizer->is_letter('#'), '# is not a letter');
}

# Tests for is_number
{
    my $tokenizer = Tokenizer->new('');
    ok($tokenizer->is_number('0'), '0 is a number');
    ok($tokenizer->is_number('9'), '9 is a number');
    ok(!$tokenizer->is_number('a'), 'a is not a number');
    ok(!$tokenizer->is_number('_'), '_ is not a number');
}

# Tests for get_next_token
{
    my $tokenizer = Tokenizer->new('let five = 5;');
    my $token = $tokenizer->get_next_token();
    is($token->{type}, $TOKEN_TYPE{Let}, 'First token type should be Let');
    is($token->{literal}, 'let', 'First token literal should be let');

    $token = $tokenizer->get_next_token();
    is($token->{type}, $TOKEN_TYPE{Ident}, 'Second token type should be Ident');
    is($token->{literal}, 'five', 'Second token literal should be five');
    
    #... and so on for each expected token in the input.
}

done_testing();

