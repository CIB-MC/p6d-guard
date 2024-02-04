package P6dGuard::Util::Nginx;
use strict;
use warnings;
use utf8;

use File::Spec ();

sub config_test {
    my ($c) = @_;
    my $command = $c->config->{command}->{nginx_config_test};
    die "no nginx_config_test in config!" if (!$command);
    return !system($command);
}

sub reload {
    my ($c) = @_;
    my $command = $c->config->{command}->{nginx_reload};
    die "no nginx_reload in config!" if (!$command);
    return !system($command);
}

sub create_allow_ips_model {
    my ($c) = @_;
    my $allow_ips_model_path = File::Spec->catdir($c->base_dir(), 'nginx', 'allow_ips.model');

    open(FH, ">", $allow_ips_model_path);
    my @whitelist = $c->db()->search('whitelist', undef, {order_by => 'last_update DESC'});
    for my $row (@whitelist) {
        printf FH "allow %s;\n", $row->ip_address;
    }
    close(FH);
}

sub clear_allow_ips_model {
    my ($c) = @_;
    my $allow_ips_model_path = File::Spec->catdir($c->base_dir(), 'nginx', 'allow_ips.model');

    open(FH, ">", $allow_ips_model_path);
    close(FH);
}

1;