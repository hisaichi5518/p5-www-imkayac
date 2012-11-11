#!perl -w
use strict;
use utf8;

use Test::More;
use Test::TCP;
use t::Util;
use WWW::ImKayac;

test_tcp(
    client => sub {
        my ($port, $server_pid) = @_;
        subtest 'posted' => sub {
            my $im = WWW::ImKayac->new(
                username => 'posted',
                password => 'test',
                authtype => 'secret_key',
                base_uri => "http://localhost:$port",
            );
            isa_ok $im, 'WWW::ImKayac';

            ok my $res = $im->post(
                message => 'message',
            );
            like $res->content, qr/"result":"posted"/;
        };

        subtest 'has handler' => sub {
            my $im = WWW::ImKayac->new(
                username => 'posted',
                password => 'test',
                authtype => 'secret_key',
                base_uri => "http://localhost:$port",
            );
            isa_ok $im, 'WWW::ImKayac';

            ok my $res = $im->post(
                message => 'message',
                handler => 'http://example.com/',
            );
            like $res->content, qr/"result":"posted"/;
        };
    },
    server => sub {
        my $port = shift;
        imkayac_mockserver($port);
    },
);

done_testing;
