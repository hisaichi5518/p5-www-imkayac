#!perl -w
use strict;
use Test::More tests => 1;

BEGIN {
    use_ok 'WWW::ImKayac';
}

diag "Testing WWW::ImKayac/$WWW::ImKayac::VERSION";
eval { require Moose };
diag "Moose/$Moose::VERSION";
eval { require Mouse };
diag "Mouse/$Mouse::VERSION";
