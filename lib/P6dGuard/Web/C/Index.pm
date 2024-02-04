package P6dGuard::Web::C::Index;
use strict;
use warnings;
use utf8;

sub redirect_member_login {
    my ($self, $c) = @_;
    return $c->redirect('/login/member/');
}

1;