#!perl -w
use strict;
use utf8;

use Test::More;
use Test::TCP;
use t::Util;

use AnyEvent;
use WWW::ImKayac::AnyEvent;

test_tcp(
    client => sub {
        my ($port, $server_pid) = @_;
        subtest 'server error' => sub {
            my $im = WWW::ImKayac::AnyEvent->new(
                base_uri => "http://localhost:$port",
            );

            my $cv = AnyEvent->condvar;
            $cv->begin;
            $im->post(
                username => 'server_error',
                password => 'test',
                authtype => 'secret_key',
                message => 'message',
                cb => sub {
                    my ($json_err, $json, $info) = @_;
                    ok $json_err;
                    $cv->end;
                },
            );
            $cv->recv;
        };

        subtest 'posted' => sub {
            my $im = WWW::ImKayac::AnyEvent->new(
                base_uri => "http://localhost:$port",
            );

            my $cv = AnyEvent->condvar;
            $cv->begin;
            $im->post(
                username => 'posted',
                password => 'test',
                authtype => 'secret_key',
                message => 'message',
                cb => sub {
                    my ($json_err, $json, $info) = @_;
                    ok !$json_err;
                    is_deeply $json, {result => 'posted', error => ''};
                    $cv->end;
                },
            );
            $cv->recv;
        };

        subtest 'multi_post' => sub {
            my $im = WWW::ImKayac::AnyEvent->new(
                base_uri => "http://localhost:$port",
            );

            $im->multi_post(
                {
                    username => 'posted',
                    password => 'test',
                    authtype => 'secret_key',
                    message => 'message',
                },
                sub {
                    my ($json_err, $json, $info) = @_;
                    ok !$json_err;
                    is_deeply $json, {result => 'posted', error => ''};
                },
            );
        };

        subtest 'has handler' => sub {
            my $im = WWW::ImKayac::AnyEvent->new(
                base_uri => "http://localhost:$port",
            );

            $im->multi_post(
                {
                    username => 'posted',
                    password => 'test',
                    authtype => 'secret_key',
                    handler  => 'http://example.com',
                    message  => 'message',
                },
                sub {
                    my ($json_err, $json, $info) = @_;
                    ok !$json_err;
                    is_deeply $json, {result => 'posted', error => ''};
                },
            );
        };
    },
    server => sub {
        my $port = shift;
        imkayac_mockserver($port);
    },
);

done_testing;
