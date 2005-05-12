#!perl

use strict;
use warnings;

use Test::More tests => 8;
use Shell::Autobox qw(perl);

is('print "hello, world"'->perl(), 'hello, world');
is('print "hello, world"'->perl->perl('-pe', 'tr/a-z/A-Z/'), 'HELLO, WORLD');

is(perl('print "hello, world"'), 'hello, world');
is(perl(perl('print "hello, world"'), '-pe', 'tr/a-z/A-Z/'), 'HELLO, WORLD');

eval { '1 = 1'->perl() };
ok ($@ =~ /Can't modify constant item in scalar assignment/);

eval { perl('1 = 1') };
ok ($@ =~ /Can't modify constant item in scalar assignment/);

eval { '1 = 1'->perl->perl('-pe', 's/1/2/') };
ok ($@ =~ /Can't modify constant item in scalar assignment/);

eval { perl(perl('1 = 1'), '-pe', 's/1/2/') };
ok ($@ =~ /Can't modify constant item in scalar assignment/);
