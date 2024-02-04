#!/usr/bin/env perl
use strict;
use warnings;
use utf8;
use lib qw(/home/p6d-guard/P6dGuard/local/lib/perl5 /home/p6d-guard/P6dGuard/lib);
use P6dGuard;
use P6dGuard::Util::Password;

my $c = P6dGuard->bootstrap();
my $line = "";

print "=== p6d-guard reset member password script ===\n";

print "Please input login_id: ";
$line = <STDIN>;
chomp($line);

if (!($line && $line =~ m/^[\p{PosixAlnum}_\-]+$/ )) {
    print "There is no input or with non-ascii char. Aborting!\n";
    exit(0);
}
my $login_id = $line;

my $member = $c->db()->single('member', {login_id => $login_id});

if (!$member) {
    print "There is no member with the login_id!\n";
    exit(0);
}

print "Please input password: ";
$line = <STDIN>;
chomp($line);

if (!($line && $line =~ m/^[\p{PosixAlnum}_\-]+$/ )) {
    print "There is no input or with non-ascii char. Aborting!\n";
    exit(0);
}
my $password = $line;

my $password_salt = P6dGuard::Util::Password::get_salt();
my $password_hash = P6dGuard::Util::Password::get_hash($password, $password_salt);

$member->update({
    login_id => $login_id,
    password_hash => $password_hash,
    password_salt => $password_salt
});

print "=== member password is reseted! ===\n";