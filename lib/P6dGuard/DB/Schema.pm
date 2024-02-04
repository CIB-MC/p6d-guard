package P6dGuard::DB::Schema;
use strict;
use warnings;
use utf8;

use Time::Piece;
use Teng::Schema::Declare;

base_row_class 'P6dGuard::DB::Row';

table {
    name 'member';
    pk 'id';
    columns qw(id login_id password_hash password_salt);
};

table {
    name 'whitelist';
    pk 'id';
    columns qw(id member_id ip_address last_update);
    inflate qr/^last_update$/ => sub { text2tp($_[0]) };
    deflate qr/^last_update$/ => sub { tp2text($_[0]) };
};

sub text2tp {
    my $str = shift or return;
    $str =~ s/\..*$//;
    return Time::Piece->strptime($str, "%Y-%m-%d %H:%M:%S");
}
sub tp2text {
    my $tp = shift or return;
    return sprintf("%s %02d:%02d:%02d", $tp->ymd, $tp->hour, $tp->min, $tp->sec);
}

1;
