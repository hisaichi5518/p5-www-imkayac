package WWW::ImKayac;
use 5.10.1;
use Mouse;

use Furl;
use Data::Validator;
use WWW::ImKayac::Util;
use HTTP::Request::Common qw(POST);

our $VERSION = '0.01';

has ua => (
    is => 'ro',
    default => sub { Furl->new },
);

has base_uri => (
    is => 'rw',
    isa => 'Str',
    default => 'http://im.kayac.com/api/post',
);

has [qw/username password authtype/] => (
    is => 'ro',
    isa => 'Str',
    required => 1,
);

has post_uri => (
    is => 'rw',
    isa => 'Str',
    default => sub {
        my ($self) = @_;
        $self->base_uri.'/'.$self->username;
    },
    lazy => 1,
);

no Mouse;

sub post {
    my $self = shift;
    state $rule = Data::Validator->new(
        message => 'Str',
        handler => {isa => 'Str', optional => 1},
    );
    my $args = $rule->validate(@_);

    my @params = WWW::ImKayac::Util::build_params(
        authtype => $self->authtype,
        username => $self->username,
        password => $self->password,
        exists $args->{handler} ? (handler  => $args->{handler}) : (),
        message  => $args->{message},
    );

    my $req = POST $self->post_uri, \@params;
    $self->ua->request($req);
}

__PACKAGE__->meta->make_immutable;
__END__

=encoding utf8

=head1 NAME

WWW::ImKayac - connection wrapper for im.kayac.com

=head1 SYNOPSIS

    use utf8;
    use WWW::ImKayac;
    use Encode qw/encode_utf8/;
    my $im = WWW::ImKayac->new(
        authtype => 'password/secret_key/none',
        username => 'im.kayac.com username',
        password => 'im.kayac.com password/secret_key',
    );

    $im->post(message => 'encoded string!');
    $im->post(message => encode_utf8 "decoded な文字列");

=head1 DESCRIPTION

WWW::ImKayac is connection wrapper for im.kayac.com.

=head1 METHODS

=head2 C<< $self->post(message => $message[, handler => $handler]) >>

    $self->post(message => $message);
    $self->post(
        message => $message,
        handler => $handler,
    );

post message for im.kayac.com.

=head1 BUGS

L<https://github.com/hisaichi5518/p5-www-imkayac/issues>

=head1 SEE ALSO

L<WebService::ImKayac>

=head1 AUTHOR

hisaichi5518

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, hisaichi5518. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
