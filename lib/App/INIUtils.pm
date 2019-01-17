package App::INIUtils;

# VERSION
# DATE

use 5.010001;

our %args_common = (
    ini => {
        summary => 'INI file',
        schema  => ['str*'],
        req     => 1,
        pos     => 0,
        cmdline_src => 'stdin_or_file',
        tags    => ['common'],
    },

    # only for parser = Config::IOD::INI::Reader
    default_section => {
        schema  => 'str*',
        default => 'GLOBAL',
        tags    => ['common', 'category:parser'],
    },
    allow_duplicate_key => {
        schema  => 'bool',
        default => 1,
        tags    => ['common', 'category:parser'],
    },
);

our %arg_parser = (
    parser => {
        summary => 'Parser to use',
        schema  => ['str*', {
            in => [
                'Config::IOD::INI::Reader',
                'Config::INI::Reader',
                'Config::IniFiles',
            ],
        }],
        default => 'Config::INI::Reader',
        tags    => ['common'],
    },
);

our %arg_inplace = (
    inplace => {
        summary => 'Modify file in-place',
        schema => ['bool', is=>1],
        description => <<'_',

Note that this can only be done if you specify an actual file and not STDIN.
Otherwise, an error will be thrown.

_
    },
);

sub _check_inplace {
    my $args = shift;
    if ($args->{inplace}) {
        die [412, "To use in-place editing, please supply an actual file"]
            if @{ $args->{-cmdline_srcfilenames_ini} // []} == 0;
        die [412, "To use in-place editing, please supply only one file"]
            if @{ $args->{-cmdline_srcfilenames_ini} // []} > 1;
    }
}

sub _return_mod_result {
    my ($args, $doc) = @_;

    if ($args->{inplace}) {
        require File::Slurper;
        File::Slurper::write_text(
            $args->{-cmdline_srcfilenames_iod}[0], $doc->as_string);
        [200, "OK"];
    } else {
        [200, "OK", $doc->as_string, {'cmdline.skip_format'=>1}];
    }
}

sub _get_cii_parser_options {
    my $args = shift;
    return (
        default_section          => $args->{default_section},
        allow_duplicate_key      => $args->{allow_duplicate_key},
    );
}

sub _get_cii_parser {
    require Config::IOD::INI;

    my $args = shift;
    Config::IOD::INI->new(
        _get_cii_parser_options($args),
    );
}

sub _get_ciir_reader {
    require Config::IOD::INI::Reader;

    my $args = shift;
    Config::IOD::INI::Reader->new(
        _get_cii_parser_options($args),
    );
}

sub _parse_str {
    my ($ini, $parser) = @_;

    if ($parser eq 'Config::INI::Reader') {
        require Config::INI::Reader;
        return Config::INI::Reader->read_string($ini);
    } elsif ($parser eq 'Config::IOD::INI::Reader') {
        require Config::IOD::INI::Reader;
        return Config::IOD::INI::Reader->new->read_string($ini);
    } elsif ($parser eq 'Config::IniFiles') {
        require Config::IniFiles;
        require File::Temp;
        my ($tempfh, $tempnam) = File::Temp::tempfile();
        print $tempfh $ini;
        close $tempfh;
        my $cfg = Config::IniFiles->new(-file => $tempnam);
        die join("\n", @Config::IniFiles::errors) unless $cfg;
        unlink $tempnam;
        return $cfg;
    } else {
        die "Unknown parser '$parser'";
    }
}

1;
# ABSTRACT: INI utilities

=head1 SYNOPSIS

This distribution provides the following command-line utilities:

#INSERT_EXECS_LIST

The main feature of these utilities is tab completion.


=head1 SEE ALSO

L<App::IODUtils>

=cut
