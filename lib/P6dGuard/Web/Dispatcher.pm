package P6dGuard::Web::Dispatcher;
use strict;
use warnings;
use utf8;
use Amon2::Web::Dispatcher::RouterBoom;
use Module::Find qw(useall);

useall('P6dGuard::Web::C');
base 'P6dGuard::Web::C';

any  '/' => 'Index#redirect_member_login';

any  '/login/member/' => 'Login::Member#index';

get  '/member/' => 'Member#index';
post '/member/add_whitelist/' => 'Member#add_whitelist';
get  '/member/logout/' => 'Member#logout';

1;
