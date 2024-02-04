package P6dGuard::Util::Password;
use strict;
use warnings;
use utf8;

use Digest::SHA qw(sha256_hex);
use String::Random qw(random_string);

sub get_hash {
    my ($pw, $salt) = @_;
    my $pw_hash = '';
    $pw_hash = sha256_hex($pw_hash . $pw . $salt) for (1 .. 1000);
    return $pw_hash;
}

sub get_salt {
    my $text = random_string(".....");
    return sha256_hex($text);
}

1;