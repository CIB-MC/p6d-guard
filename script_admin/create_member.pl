#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use lib qw(/home/p6d-guard/P6dGuard/local/lib/perl5 /home/p6d-guard/P6dGuard/lib);
use P6dGuard;
use P6dGuard::Util::Password;

my $c = P6dGuard->bootstrap();

my $password_salt = P6dGuard::Util::Password::get_salt();
my $password_hash = P6dGuard::Util::Password::get_hash('p6dadmin', $password_salt);

$c->db()->insert('member', {
    login_id => 'p6dadmin',
    password_hash => $password_hash,
    password_salt => $password_salt
});