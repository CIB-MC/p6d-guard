package P6dGuard::Web::C::Login::Member;
use strict;
use warnings;
use utf8;
use P6dGuard::Util::Password;

sub index {
    my ($self, $c) = @_;
    return $c->render("login/member/index.tt") if ($c->req->method ne 'POST');

    my $req_param = $c->req->parameters;
    my $member = $c->db()->single('member', {login_id => $req_param->{login_id}});
    $c->validator()->set_error('credential', 'correct') if (!$member);
    return $c->render("login/member/index.tt") if ($c->validator()->has_error);

    my $password_salt = $member->password_salt;
    my $password_hash = P6dGuard::Util::Password::get_hash($req_param->{password}, $password_salt);
    $c->validator()->set_error('credential', 'correct') if ($password_hash ne $member->password_hash);
    return $c->render("login/member/index.tt") if ($c->validator()->has_error);

    $c->session->regenerate_id();
    $c->session->set('member_id' => $member->id);
    return $c->redirect('/member/');
}

1;