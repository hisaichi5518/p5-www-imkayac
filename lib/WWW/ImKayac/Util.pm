package WWW::ImKayac::Util;
use 5.10.1;
use strict;
use warnings;
use Digest::SHA1 qw(sha1_hex);
use Carp qw(croak);

sub build_params {
    state $rule = Data::Validator->new(
        message  => 'Str',
        username => 'Str',
        password => 'Str',
        authtype => 'Str',
    );
    my $args = $rule->validate(@_);

    my $message  = $args->{message};
    my $authtype = $args->{authtype};
    my $username = $args->{username};
    my $password = $args->{password};

    my @params;
    if ($authtype eq 'secret_key') {
        @params = (
            sig     => sha1_hex($message.$password),
            message => $message ,
        );
    }
    elsif ($authtype eq 'password') {
        @params = (
            password => $password,
            message  => $message,
        );
    }
    else {
        croak "authtype isnt password/secret_key";
    }

    return @params;
}


1;
