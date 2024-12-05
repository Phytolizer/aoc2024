#!/usr/bin/env perl
use feature qw{ say };
use strict;
use warnings;

sub natatime($@) {
    my $n    = shift;
    my @list = @_;
    return sub { return splice @list, 0, $n; }
}

my $mulPattern = qr/mul\((\d+),(\d+)\)/;

my $enabled    = 1;
my $sum        = 0;
my $enabledSum = 0;
while (<STDIN>) {
    while (m/$mulPattern|do\(\)|don't\(\)/g) {
        my $len  = $+[0] - $-[0];
        my $text = substr $_, $-[0], $len;
        if ( $text eq "do()" ) {
            $enabled = 1;
        }
        elsif ( $text eq "don't()" ) {
            $enabled = 0;
        }
        else {
            $sum += $1 * $2;
            if ($enabled) {
                $enabledSum += $1 * $2;
            }
        }
        pos $_ = $+[0];
    }
}

say "Part 1: $sum";
say "Part 2: $enabledSum";
