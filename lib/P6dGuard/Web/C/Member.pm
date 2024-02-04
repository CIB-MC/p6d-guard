package P6dGuard::Web::C::Member;
use strict;
use warnings;
use utf8;

use Time::Piece;
use P6dGuard::Util::Nginx;
use P6dGuard::Util::SystemInfo;
use P6dGuard::Util::GameServer;

sub index {
    my ($self, $c) = @_;
    my $req_param = $c->req->parameters;
    my $ip_address = "";

    my $client_ip_address = $c->req->address;

    my @whitelist = $c->db()->search('whitelist', undef, {
        order_by => 'last_update DESC'
    });

    return $c->render('member/index.tt', {
        client_ip_address => $client_ip_address,
        whitelist => \@whitelist
    }) if ($c->req->method ne 'POST');

    if ($req_param->{update_by_client_ip}) {
        $ip_address = $client_ip_address;
    } elsif ($req_param->{update_by_input}) {
        $c->validator()->check(
            ip_address => [[REGEX => qr/^((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)|(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])))$/]]
        );
        $ip_address = $req_param->{ip_address} if (!($c->validator()->has_error));
    } else {
        $c->validator()->set_error('operation', 'setted');
    }

    return $c->render('member/index.tt', {
        client_ip_address => $client_ip_address,
        whitelist => \@whitelist
    }) if ($c->validator()->has_error);

    my $now = localtime;
    my $row = $c->db()->single('whitelist', {
        member_id => $c->logged_in_member()->id,
        ip_address => $ip_address
    });

    my $txn = $c->db()->txn_scope;
    if ($row) {
        $row->update({last_update => $now});
    } else {
        $c->db()->insert('whitelist', {
            member_id => $c->logged_in_member()->id,
            ip_address => $ip_address,
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
            whitelist => \@whitelist,
            failed => 1
        });
    }
    P6dGuard::Util::Nginx::reload($c);

    $txn->commit;

    @whitelist = $c->db()->search('whitelist', undef, {
        order_by => 'last_update DESC'
    });

    return $c->render('member/index.tt', {
        client_ip_address => $client_ip_address,
        whitelist => \@whitelist,
        success => 1
    });
}

sub ip_delete {
    my ($self, $c) = @_;
    my $req_param = $c->req->parameters;

    my $row_id = $req_param->{row_id};
    return $c->redirect('/member/?failed=1') if (!$row_id);

    my $row = $c->db()->single('whitelist', {
        id => $row_id,
        member_id => $c->logged_in_member()->id
    });
    return $c->redirect('/member/?failed=1') if (!$row);

    $row->delete();
    P6dGuard::Util::Nginx::create_allow_ips_model($c);
    if (!P6dGuard::Util::Nginx::config_test($c)) {
        P6dGuard::Util::Nginx::clear_allow_ips_model($c);
        return $c->redirect('/member/?failed=1');
    }
    P6dGuard::Util::Nginx::reload($c);
    return $c->redirect('/member/?success=1');
}

sub system {
    my ($self, $c) = @_;
    my $req_param = $c->req->parameters;

    my $memory_usage = P6dGuard::Util::SystemInfo::get_memory_usage;
    my $game_server_is_active = P6dGuard::Util::GameServer::is_active($c);

    return $c->render('member/system.tt', {
        memory_usage => $memory_usage,
        game_server_is_active => $game_server_is_active
    }) if ($c->req->method ne 'POST');

    if ($req_param->{server_start}) {
        if (P6dGuard::Util::GameServer::is_active($c)) {
            return $c->redirect('/member/system/?failed=1');
        }
        if (!P6dGuard::Util::GameServer::start($c)) {
            return $c->redirect('/member/system/?failed=1');
        }
    } elsif ($req_param->{server_restart}) {
        if (!P6dGuard::Util::GameServer::is_active($c)) {
            return $c->redirect('/member/system/?failed=1');
        }
        if (!P6dGuard::Util::GameServer::restart($c)) {
            return $c->redirect('/member/system/?failed=1');
        }
    } elsif ($req_param->{server_stop}) {
        if (!P6dGuard::Util::GameServer::is_active($c)) {
            return $c->redirect('/member/system/?failed=1');
        }
        if (!P6dGuard::Util::GameServer::stop($c)) {
            return $c->redirect('/member/system/?failed=1');
        }
    } else {
        return $c->redirect('/member/system/?failed=1');
    }

    $game_server_is_active = P6dGuard::Util::GameServer::is_active($c);
    return $c->render('member/system.tt', {
        memory_usage => $memory_usage,
        game_server_is_active => $game_server_is_active,
        success => 1
    })
}

sub logout {
    my ($self, $c) = @_;
    $c->session->remove('member_id');
    return $c->redirect('/login/member/');
}

1;