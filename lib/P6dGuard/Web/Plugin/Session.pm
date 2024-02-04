package P6dGuard::Web::Plugin::Session;
use strict;
use warnings;
use utf8;

use Amon2::Util;
use HTTP::Session2::ServerStore;
use Cache::Memcached::Fast::Safe;

sub init {
    my ($class, $c) = @_;

    # Validate XSRF Token.
    $c->add_trigger(
        BEFORE_DISPATCH => sub {
            my ( $c ) = @_;
            if ($c->req->method ne 'GET' && $c->req->method ne 'HEAD') {
                my $token = $c->req->header('X-XSRF-TOKEN') || $c->req->param('XSRF-TOKEN');
                unless ($c->session->validate_xsrf_token($token)) {
                    return $c->create_simple_status_page(
                        403, 'XSRF detected.'
                    );
                }
            }
            return;
        },
    );

    Amon2::Util::add_method($c, 'session', \&_session);

    # Inject cookie header after dispatching.
    $c->add_trigger(
        AFTER_DISPATCH => sub {
            my ( $c, $res ) = @_;
            if ($c->{session} && $res->can('cookies')) {
                $c->{session}->finalize_plack_response($res);
            }
            return;
        },
    );
}

# $c->session() accessor.
sub _session {
    my $self = shift;

    if (!exists $self->{session}) {
        $self->{session} = HTTP::Session2::ServerStore->new(
            env => $self->req->env,
            secret => 'YcygUI1yDIi-qIOvrurKtTjtbmC0Pf0a',
            store => Cache::Memcached::Fast::Safe->new({
                servers => ['127.0.0.1:11211'],
                        namespace => 'p6dguard::session::',
                hash_namespace => 1
            }),
            session_cookie => {
               httponly => 1,
               secure   => 0,
               name => 'hss_session',
               path => '/',
               samesite => 'Lax'
            },
            xsrf_cookie => {
                httponly => 0,
                secure   => 0,
                name     => 'XSRF-TOKEN',
                path     => '/',
                samesite => 'Strict'
            }
        );
    }
    return $self->{session};
}

1;
__END__

=head1 DESCRIPTION

This module manages session for P6dGuard.

