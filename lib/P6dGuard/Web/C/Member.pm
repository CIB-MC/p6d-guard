package P6dGuard::Web::C::Member;
use strict;
use warnings;
use utf8;

use Time::Piece;

sub index {
    my ($self, $c) = @_;
    my $client_ip_address = $c->req->address;

    my @whitelist = $c->db()->search('whitelist', undef, {
        order_by => 'last_update DESC'
    });

    return $c->render('member/index.tt', {
        client_ip_address => $client_ip_address,
        whitelist => \@whitelist
    });
}

sub add_whitelist {
    my ($self, $c) = @_;
    my $client_ip_address = $c->req->address;

    my $now = localtime;
    my $row = $c->db()->single('whitelist', {
        member_id => $c->logged_in_member()->id,
        ip_address => $client_ip_address
    });

    if ($row) {
        $row->update({last_update => $now});
    } else {
        $c->db()->insert('whitelist', {
            member_id => $c->logged_in_member()->id,
            ip_address => $client_ip_address,
            last_update => $now
        });
    }
    return $c->redirect('/member/');
}

sub logout {
    my ($self, $c) = @_;
    $c->session->remove('member_id');
    return $c->redirect('/login/member/');
}

1;