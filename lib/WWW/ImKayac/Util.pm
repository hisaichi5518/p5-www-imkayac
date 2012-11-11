package WWW::ImKayac::Util;
use 5.10.1;
use strict;
use warnings;
use Digest::SHA1 qw(sha1_hex);
use Carp qw(croak);
use Data::Validator;

sub build_params {
    state $rule = Data::Validator->new(
        username => 'Str',
        password => 'Str',
        authtype => 'Str',
        handler  => {isa => 'Str', optional => 1},
        message  => 'Str',
    );
    my $args = $rule->validate(@_);

    my $authtype = $args->{authtype};
    my $username = $args->{username};
    my $password = $args->{password};
    my $handler  = exists $args->{handler} ? $args->{handler} : undef;
    my $message  = $args->{message};

    my @params;
    if ($authtype eq 'secret_key') {
        @params = (
            sig     => sha1_hex($message.$password),
            handler => $handler,
            message => $message ,
        );
    }
    elsif ($authtype eq 'password') {
        @params = (
            password => $password,
            handler => $handler,
            message  => $message,
        );
    }
    else {
        croak "authtype isnt password/secret_key";
    }

    return @params;
}


1;
