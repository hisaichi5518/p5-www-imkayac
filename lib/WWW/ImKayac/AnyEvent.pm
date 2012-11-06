package WWW::ImKayac::AnyEvent;
use 5.10.1;
use Mouse;

use AnyEvent;
use AnyEvent::HTTP;
use WWW::ImKayac::Util;
use HTTP::Request::Common qw(POST);
use JSON::XS qw(decode_json);

has base_uri => (
    is => 'rw',
    isa => 'Str',
    default => 'http://im.kayac.com/api/post',
);

no Mouse;

sub multi_post {
    my $cb = pop @_;
    my ($self, @user_info) = @_;

    my $cv = AnyEvent->condvar;
    for my $user (@user_info) {
        $cv->begin;
        $self->post(%$user, cb => sub {
            $cb->(@_);
            $cv->end;
        });
    }
    $cv->recv;
}

sub post {
    my ($self, %args) = @_;
    my $authtype = $args{authtype};
    my $username = $args{username};
    my $password = $args{password};
    my $message  = $args{message};
    my $cb = $args{cb};

    my @params = WWW::ImKayac::Util::build_params(
        authtype => $authtype,
        username => $username,
        password => $password,
        message  => $message,
    );

    my $req = POST $self->base_uri."/$username", \@params;
    http_post $req->uri, $req->content, headers => $req->headers, sub {
        my ($body, $headers) = @_;

        my $json = eval { decode_json $body };
        $cb->($@, $json, {
            authtype => $authtype,
            username => $username,
            password => $password,
            message  => $message,
            body     => $body,
            headers  => $headers,
        });
    };
}

__PACKAGE__->meta->make_immutable;
__END__

=encoding utf8

=head1 NAME

WWW::ImKayac::AnyEvent - connection wrapper for im.kayac.com

=head1 SYNOPSIS

    use utf8;
    use WWW::ImKayac::AnyEvent;
    use AnyEvent;

    my $im = WWW::ImKayac::AnyEvent->new;
    my @user_info = (
        {
            authtype => 'password/secret_key/none',
            username => 'im.kayac.com username',
            password => 'im.kayac.com password/secret_key',
            message  => 'encoded string!',
        },
        {
            authtype => 'password/secret_key/none',
            username => 'im.kayac.com username',
            password => 'im.kayac.com password/secret_key',
            message  => 'encoded string!',
        },
    );
    my $cv = AnyEvent->condvar;
    for my $user (@user_info) {
        $cv->begin;
        $im->post(%$user, cb => sub {
            my ($json_err, $json, $info) = @_;
            ...;
            $cv->end;
        });
    }
    $cv->recv;

    $im->multi_post(@user_info, sub {
        my ($json_err, $json, $info) = @_;
        ...;
    });

=head1 DESCRIPTION

WWW::ImKayac is connection wrapper for im.kayac.com.

=head1 METHODS

=head2 C<< $self->post(%args) >>

    my @user_info = (
        {
            authtype => 'password/secret_key/none',
            username => 'im.kayac.com username',
            password => 'im.kayac.com password/secret_key',
            message  => 'encoded string!',
        },
        ...
    );
    my $cv = AnyEvent->condvar;
    for my $user (@user_info) {
        $cv->begin;
        $im->post(%$user, cb => sub {
            my ($json_err, $json, $info) = @_;
            ...;
            $cv->end;
        });
    }
    $cv->recv;

post message for im.kayac.com. use L<AnyEvent::HTTP>

=head2 C<< $self->multi_post(@user_info, \&callback) >>

    my @user_info = (
        {
            authtype => 'password/secret_key/none',
            username => 'im.kayac.com username',
            password => 'im.kayac.com password/secret_key',
            message  => 'encoded string!',
        },
        ...
    );
    $self->multi_post(
        @user_info, sub {
            my ($json_err, $json, $info) = @_;
            ...;
        },
    );

post message for im.kayac.com. use L<AnyEvent>, L<AnyEvent::HTTP>

=head1 SEE ALSO

L<WWW::ImKayac>, L<AnyEvent::WebService::ImKayac>

=head1 AUTHOR

hisaichi5518

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, hisaichi5518. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
