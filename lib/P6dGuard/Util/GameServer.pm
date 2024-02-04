package P6dGuard::Util::GameServer;
use strict;
use warnings;
use utf8;

sub is_active {
    my ($c) = @_;
    my $command = $c->config->{command}->{game_server_status};
    die "no game_server_status in config!" if (!$command);
    my @res = `$command`;
    return 0 if (!($res[2]));
    return ($res[2] =~ m/^\s*Active: active/) ? 1 : 0;
}

sub start {
    my ($c) = @_;
    my $command = $c->config->{command}->{game_server_start};
    die "no game_server_start in config!" if (!$command);
    return !system($command);
}

sub restart {
    my ($c) = @_;
    my $command = $c->config->{command}->{game_server_restart};
    die "no game_server_restart in config!" if (!$command);
    return !system($command);
}

sub stop {
    my ($c) = @_;
    my $command = $c->config->{command}->{game_server_stop};
    die "no game_server_stop in config!" if (!$command);
    return !system($command);
}

1;