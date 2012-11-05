package WWW::ImKayac::AnyEvent;
use 5.10.1;
use Mouse;

use AnyEvent;
use AnyEvent::HTTP;
use WWW::ImKayac::Util;
use HTTP::Request::Common qw(POST);

has base_uri => (
    is => 'rw',
    isa => 'Str',
    default => 'http://im.kayac.com/api/post',
);

no Mouse;

sub post {
    my ($self, @user_info) = @_;

    my @data;
    my $cv = AnyEvent->condvar;
    for my $user (@user_info) {
        $cv->begin;
        my $authtype = $user->{authtype};
        my $username = $user->{username};
        my $password = $user->{password};
        my $message  = $user->{message};

        my @params = WWW::ImKayac::Util::build_params(
            authtype => $authtype,
            username => $username,
            password => $password,
            message  => $message,
        );

        my $req = POST $self->base_uri."/$username", \@params;
        http_post $req->uri, $req->content, headers => $req->headers, sub {
            my ($body, $headers) = @_;
            push @data, {
                authtype => $authtype,
                username => $username,
                password => $password,
                message  => $message,
                body     => $body,
                headers  => $headers
            };
            $cv->end;
        };
    }
    $cv->recv;

    return @data;
}

__PACKAGE__->meta->make_immutable;
