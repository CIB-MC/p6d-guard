package P6dGuard::Web::C::Member;
use strict;
use warnings;
use utf8;

use Time::Piece;
use P6dGuard::Util::Nginx;

sub index {
    my ($self, $c) = @_;
    my $client_ip_address = $c->req->address;

    my @whitelist = $c->db()->search('whitelist', undef, {
        order_by => 'last_update DESC'
    });

    return $c->render('member/index.tt', {
        client_ip_address => $client_ip_address,
        whitelist => \@whitelist
    }) if ($c->req->method ne 'POST');

    my $now = localtime;
    my $row = $c->db()->single('whitelist', {
        member_id => $c->logged_in_member()->id,
        ip_address => $client_ip_address
    });

    my $txn = $c->db()->txn_scope;
    if ($row) {
        $row->update({last_update => $now});
    } else {
        $c->db()->insert('whitelist', {
            member_id => $c->logged_in_member()->id,
            ip_address => $client_ip_address,
            last_update => $now
        });
    }

    P6dGuard::Util::Nginx::create_allow_ips_model($c);
    if (!P6dGuard::Util::Nginx::config_test($c)) {
        P6dGuard::Util::Nginx::clear_allow_ips_model($c);

        @whitelist = $c->db()->search('whitelist', undef, {
            order_by => 'last_update DESC'
        });

        return $c->render('member/index.tt', {
            client_ip_address => $client_ip_address,
            whitelist => \@whitelist
        });
    }
    P6dGuard::Util::Nginx::reload($c);

    $txn->commit;

    @whitelist = $c->db()->search('whitelist', undef, {
        order_by => 'last_update DESC'
    });

    return $c->render('member/index.tt', {
        client_ip_address => $client_ip_address,
        whitelist => \@whitelist
    });
}

sub logout {
    my ($self, $c) = @_;
    $c->session->remove('member_id');
    return $c->redirect('/login/member/');
}

1;