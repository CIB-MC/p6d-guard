package P6dGuard::Web;
use strict;
use warnings;
use utf8;
use parent qw/P6dGuard Amon2::Web/;
use File::Spec;
use POSIX;

use constant KiB_MiB => 1024;
use constant KiB_GiB => 1024*1024; 

# dispatcher
use P6dGuard::Web::Dispatcher;
sub dispatch {
    return (P6dGuard::Web::Dispatcher->dispatch($_[0]) or die "response is not generated");
}

# load plugins
__PACKAGE__->load_plugins(
    'Web::FillInFormLite',
    'Web::JSON',
    '+P6dGuard::Web::Plugin::Session',
    '+P6dGuard::Web::Hook::LoginCheck',
);

# setup view
use P6dGuard::Web::View;
{
    sub create_view {
        my $view = P6dGuard::Web::View->make_instance(__PACKAGE__);
        no warnings 'redefine';
        *P6dGuard::Web::create_view = sub { $view }; # Class cache.
        $view
    }
}

# for your security
__PACKAGE__->add_trigger(
    AFTER_DISPATCH => sub {
        my ( $c, $res ) = @_;

        # http://blogs.msdn.com/b/ie/archive/2008/07/02/ie8-security-part-v-comprehensive-protection.aspx
        $res->header( 'X-Content-Type-Options' => 'nosniff' );

        # http://blog.mozilla.com/security/2010/09/08/x-frame-options/
        $res->header( 'X-Frame-Options' => 'DENY' );

        # Cache control.
        $res->header( 'Cache-Control' => 'private' );
    },
);

use FormValidator::Lite;
FormValidator::Lite->load_constraints(qw/Email Date File URL/);
sub validator {
    my $c = shift;
    $c->{validator} ||= FormValidator::Lite->new($c->req);
}

sub byte_to_gigabyte {
    my ($c, $byte) = @_;
    my $gigabyte_sect = POSIX::floor($byte / KiB_GiB);
    my $megabyte_sect = POSIX::floor(($byte - $gigabyte_sect * KiB_GiB) / KiB_MiB);
    return $gigabyte_sect . "." . $megabyte_sect; 
}

1;
