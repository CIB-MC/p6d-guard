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

any  '/member/' => 'Member#index';
post '/member/ip_delete/' => 'Member#ip_delete';
get  '/member/logout/' => 'Member#logout';

1;
