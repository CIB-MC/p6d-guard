use File::Spec;
use File::Basename qw(dirname);
my $basedir = File::Spec->rel2abs(File::Spec->catdir(dirname(__FILE__), '..'));
my $dbpath = File::Spec->catfile($basedir, 'production.db');
+{
    'DBI' => [
        "dbi:SQLite:dbname=$dbpath", '', '',
        +{
            sqlite_unicode => 1,
        }
    ],
    'command' => {
        game_server_status => 'sudo systemctl status palworld-dedicated.service',
        game_server_start => 'sudo systemctl start palworld-dedicated.service',
        game_server_restart => 'sudo systemctl restart palworld-dedicated.service',
        game_server_stop => 'sudo systemctl stop palworld-dedicated.service',
        nginx_config_test => 'sudo nginx -t',
        nginx_reload => 'sudo systemctl reload nginx.service'
    }
};
