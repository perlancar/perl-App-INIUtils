package App::INIUtils::Common;

use 5.010001;
use strict;
use warnings;

our %args_grep = (
    section => {
        schema => 'str*',
    },
    key => {
        schema => 'str*',
    },
    value => {
        schema => 'str*',
    },
    ignore_case => {
        schema => 'bool*',
        cmdline_aliases => {i=>{}},
    },
    invert_match => {
        schema => 'bool*',
        cmdline_aliases => {v=>{}},
    },
    invert_match_section => {
        schema => 'bool*',
    },
    invert_match_key => {
        schema => 'bool*',
    },
    invert_match_value => {
        schema => 'bool*',
    },
);

sub grep_hoh {
    my %args = @_;

    my $ci = $args{ignore_case};
    my $invert = $args{invert_match};

    my $section = $args{section}; $section = lc $section if defined $section && $ci;
    my $key     = $args{key};     $key     = lc $key     if defined $key     && $ci;
    my $value   = $args{value};   $value   = lc $value   if defined $value   && $ci;

    my $hoh = $args{hoh};
    my $new_hoh = {};
    for my $s (sort keys %$hoh) {
        my $match = 1;

        # filter section
        if (defined $section) {
            if ($ci) {
                $match = index(lc($s), $section) >= 0;
            } else {
                $match = index($s, $section) >= 0;
            }
        }
        $match = !$match if (defined $section && $invert) || $args{invert_match_value};
        next unless $match;

        $new_hoh->{$s} = {};

        my $hash = $hoh->{$s};
        for my $k (sort keys %$hash) {
            my $match = 1;

            # filter key
            if (defined $key) {
                if ($ci) {
                    $match = index(lc($k), $key) >= 0;
                } else {
                    $match = index($k, $key) >= 0;
                }
            }
            $match = !$match if (defined $key && $invert) || $args{invert_match_key};
            next unless $match;

            # filter value
            my $v = $hash->{$k};
            if (defined $value) {
                if ($ci) {
                    $match = index(lc($v), $value) >= 0;
                } else {
                    $match = index($v, $value) >= 0;
                }
            }
            $match = !$match if (defined $value && $invert) || $args{invert_match_value};
            next unless $match;

            $new_hoh->{$s}{$k} = $v;
        }
    }
    $new_hoh;
}

sub hoh_as_ini {
    my $hoh = shift;
    join(
        "",
        map {
            my $s = $_;
            my $hash = $hoh->{$s};
            join(
                "",
                "[$s]\n",
                map {
                    "$_=$hash->{$_}\n"
                } sort keys %$hash,
            );
        } sort keys %$hoh
    );
}

1;
# ABSTRACT: Routines common between App::INIUtils and App::IODUtils
