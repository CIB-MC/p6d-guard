package P6dGuard::Web::Hook::LoginCheck;
use strict;
use warnings;
use utf8;

use Amon2::Util;

sub init {
    my ($class, $c) = @_;
    $c->add_trigger(
        BEFORE_DISPATCH => sub {
            my ($self) = @_;
            Amon2::Util::add_method($c, logged_in_member => \&logged_in_member);

            if (my $member_id = $self->session->get('member_id')) {
                $self->{logged_in_member} =  $self->db->single('member', {id => $member_id});
            }

            my $path = $self->req->path;
            if ($path =~ m!^/member/.*$!) {
                return $self->redirect('/login/member/') if !$self->{logged_in_member};
            }
            return;
        }
    );
}

sub logged_in_member { return shift->{logged_in_member} }

1;