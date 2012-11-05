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
    );
    my $args = $rule->validate(@_);

    my @params = WWW::ImKayac::Util::build_params(
        authtype => $self->authtype,
        username => $self->username,
        password => $self->password,
        message  => $args->{message},
    );

    my $req = POST $self->post_uri, \@params;
    $self->ua->request($req);
}

__PACKAGE__->meta->make_immutable;
__END__

=head1 NAME

WWW::ImKayac - Perl extention to do something

=head1 VERSION

This document describes WWW::ImKayac version 0.01.

=head1 SYNOPSIS

    use WWW::ImKayac;

=head1 DESCRIPTION

# TODO

=head1 INTERFACE

=head2 Functions

=head3 C<< hello() >>

# TODO

=head1 DEPENDENCIES

Perl 5.8.1 or later.

=head1 BUGS

All complex software has bugs lurking in it, and this module is no
exception. If you find a bug please either email me, or add the bug
to cpan-RT.

=head1 SEE ALSO

L<perl>

=head1 AUTHOR

hisaichi5518 E<lt>info[at]moe-project.comE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (c) 2012, hisaichi5518. All rights reserved.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
