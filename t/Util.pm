package t::Util;
use strict;
use warnings;
use parent 'Exporter';

our @EXPORT = qw/imkayac_mockserver/;

use Plack::Request;
use Plack::Runner;

sub imkayac_mockapp {
    return sub {
        my $env = shift;
        my $path_info = $env->{PATH_INFO} || '/';

        my @res = (404, [], ['no test']);
        if ($path_info =~ m{/server_error$}) {
            @res = (500, [], ['server error']);
        }
        elsif ($path_info  =~ m{/posted$}) {
            @res = (200, [], ['{"result":"posted", "error":""}']);
        }

        return \@res;
    }
}

sub imkayac_mockserver {
    my ($port) = @_;
    my $runner = Plack::Runner->new;
    $runner->parse_options('-p' => $port);
    $runner->run(imkayac_mockapp());
}

1;
