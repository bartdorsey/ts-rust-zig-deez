#!/usr/bin/perl
package Tokenizer;
use strict;
use warnings;
use feature "switch";
no warnings 'experimental::smartmatch';
use Exporter qw(import);

our @EXPORT_OK = qw(%TOKEN_TYPE create_token);

our %TOKEN_TYPE = (
    Illegal => "ILLEGAL",
    Eof => "EOF",
    Ident => "IDENT",
    If => "if",
    Return => "return",
    True => "true",
    False => "false",
    Else => "else",
    Int => "INT",
    Assign => "=",
    NotEqual => "!=",
    Equal => "==",
    Plus => "+",
    Comma => ",",
    Semicolon => ";",
    LParen => "(",
    RParen => ")",
    LSquirly => "{",
    RSquirly => "}",
    Function => "FUNCTION",
    Let => "LET",
    Bang => "!",
    Dash => "-",
    ForwardSlash => "/",
    Asterisk => "*",
    LessThan => "<",
    GreaterThan => ">",
);

sub create_token {
    my ($type, $literal) = @_;
    return { type => $type, literal => $literal };
}

our %KEYWORDS = (
    "fn" => create_token($TOKEN_TYPE{Function}, "fn"),
    "let" => create_token($TOKEN_TYPE{Let}, "let"),
    "return" => create_token($TOKEN_TYPE{Return}, "return"),
    "true" => create_token($TOKEN_TYPE{True}, "true"),
    "false" => create_token($TOKEN_TYPE{False}, "false"),
    "if" => create_token($TOKEN_TYPE{If}, "if"),
    "else" => create_token($TOKEN_TYPE{Else}, "else"),
);


sub new {
    my ($class, $input) = @_;
    my $self = { position => 0, read_position => 0, ch => '', input => $input };
    bless $self, $class;
    $self->read_char();
    return $self
}

sub is_letter {
    my ($self, $ch) = @_;
    return $ch =~ /[a-zA-Z_]/;
}

sub is_number {
    my ($self, $ch) = @_;
    return $ch =~ /[0-9]/;
}

sub read_char {
    my $self = shift;
    
    if ($self->{read_position} >= length $self->{input}) {
        $self->{ch} = "\0";
    } else {
        $self->{ch} = substr($self->{input}, $self->{read_position}, 1);
    }
    
    $self->{position} = $self->{read_position};
    $self->{read_position}++;
}

sub peek {
    my $self = shift;
    if ($self->{read_position} >= length $self->{input}) {
        return "\0";
    } else {
        return substr($self->{input}, $self->{read_position}, 1);
    }
}

sub read_ident {
    my $self = shift;
    my $position = $self->{position};

    while ($self->is_letter($self->{ch})) {
        $self->read_char();
    }

    return substr($self->{input}, $position, $self->{position} - $position);
}

sub read_int {
    my $self = shift;
    my $position = $self->{position};

    while ($self->is_number($self->{ch})) {
        $self->read_char();
    }

    return substr($self->{input}, $position, $self->{position} - $position);
}

sub skip_whitespace {
    my $self = shift;

    while ($self->{ch} =~ /\s/) {
        $self->read_char();
    }
}

sub get_next_token {
    my $self = shift;
    $self->skip_whitespace();
    my $ch = $self->{ch};
    my $tok;

    given ($ch) {
        when ('{') { $tok = create_token($TOKEN_TYPE{LSquirly}, $ch); }
        when ('}') { $tok = create_token($TOKEN_TYPE{RSquirly}, $ch); }
        when ('(') { $tok = create_token($TOKEN_TYPE{LParen}, $ch); }
        when (')') { $tok = create_token($TOKEN_TYPE{RParen}, $ch); }
        when (',') { $tok = create_token($TOKEN_TYPE{Comma}, $ch); }
        when ('!') {
            if ($self->peek() eq '=') {
                $self->read_char();
                $tok = create_token($TOKEN_TYPE{NotEqual}, '!=');
            } else {
                $tok = create_token($TOKEN_TYPE{Bang}, $ch);
            }
        }
        when ('>') { $tok = create_token($TOKEN_TYPE{GreaterThan}, $ch); }
        when ('<') { $tok = create_token($TOKEN_TYPE{LessThan}, $ch); }
        when ('*') { $tok = create_token($TOKEN_TYPE{Asterisk}, $ch); }
        when ('/') { $tok = create_token($TOKEN_TYPE{ForwardSlash}, $ch); }
        when ('-') { $tok = create_token($TOKEN_TYPE{Dash}, $ch); }
        when (';') { $tok = create_token($TOKEN_TYPE{Semicolon}, $ch); }
        when ('+') { $tok = create_token($TOKEN_TYPE{Plus}, $ch); }
        when ('=') {
            if ($self->peek() eq '=') {
                $self->read_char();
                $tok = create_token($TOKEN_TYPE{Equal}, '==');
            } else {
                $tok = create_token($TOKEN_TYPE{Assign}, $ch);
            }
        }
        when ("\0") { $tok = create_token($TOKEN_TYPE{Eof}, 'eof'); }
        default {
            if ($self->is_letter($ch)) {
                my $ident = $self->read_ident();
                return $KEYWORDS{$ident} // create_token($TOKEN_TYPE{Ident}, $ident);
            } elsif ($self->is_number($ch)) {
                return create_token($TOKEN_TYPE{Int}, $self->read_int());
            } else {
                $tok = create_token($TOKEN_TYPE{Illegal}, $ch);
            }
        }
    }

    $self->read_char();
    return $tok;
}

1;
