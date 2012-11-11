package WWW::ImKayac::Util;
use 5.10.1;
use strict;
use warnings;
use Digest::SHA1 qw(sha1_hex);
use Carp qw(croak);

sub build_params {
    my (%args) = @_;
    my $authtype = $args{authtype};
    my $username = $args{username};
    my $password = $args{password};
    my $message  = $args{message};
    my $handler  = $args{handler};

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
    elsif ($authtype eq 'none') {
        @params = (
            handler => $handler,
            message  => $message,
        );
    }
    else {
        croak "authtype isnt password/secret_key/none";
    }

    return @params;
}


1;
__END__

=encoding utf8

=head1 NAME

WWW::ImKayac::Util - utility for WWW::ImKayac

=head1 FUNCTIONS

=head2 C<< build_params(%params) -> Array >>

=cut
