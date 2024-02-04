package P6dGuard::Util::SystemInfo;
use strict;
use warnings;
use utf8;

sub get_memory_usage {
    my $res = {
        mem => undef,
        swap => undef
    };
    my @result = `free`;

    for my $r (@result) {
        if ($r =~ m/^Mem:\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/) {
            $res->{mem} = {
                total      => int($1),
                used       => int($2),
                free       => int($3),
                shared     => int($4),
                buff_cache => int($5),
                available  => int($6)
            };
        }
        if ($r =~ m/^Swap:\s+(\d+)\s+(\d+)\s+(\d+)$/) {
            $res->{swap} = {
                total      => int($1),
                used       => int($2),
                free       => int($3)
            };
        }
    }

    return $res;
}

1;