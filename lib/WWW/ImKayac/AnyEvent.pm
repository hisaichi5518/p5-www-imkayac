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




