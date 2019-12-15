package App::INIUtils;

# VERSION
# AUTHORITY
# DATE
# DIST

use 5.010001;

use Sort::Sub;

our %SPEC;

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
        my $cfg = Config::IniFiles->new(-file => \$ini);
        die join("\n", @Config::IniFiles::errors) unless $cfg;
        return $cfg;
    } else {
        die "Unknown parser '$parser'";
    }
}

sub _dump_str {
    my ($ini, $parser) = @_;
    my $res = _parse_str($ini, $parser);
    if ($parser eq 'Config::IniFiles') {
        $res = $res->{v};
    }
    $res;
}

$SPEC{sort_ini_sections} = {
    v => 1.1,
    summary => '',
    args => {
        %App::INIUtils::args_common,
        %Sort::Sub::argsopt_sortsub,
    },
    result_naked => 1,
};
sub sort_ini_sections {
    my %args = @_;

    my $parser = App::INIUtils::_get_cii_parser(\%args);

    my $doc = $parser->read_string($args{ini});
    my @raw_lines = split /^/, $args{ini};

    my $sortsub_routine = $args{sort_sub} // 'asciibetically';
    my $sortsub_args    = $args{sort_args} // {};
    my $sorter = Sort::Sub::get_sorter($sortsub_routine, $sortsub_args);

    my @sections;
    $doc->each_section(
        sub {
            my ($self, %cargs) = @_;
            push @sections, \%cargs;
        });

    @sections = sort { $sorter->($a->{section}, $b->{section}) } @sections;

    my @res;
    for my $section (@sections) {
        my @section_lines = @raw_lines[ $section->{linum_start}-1 .. $section->{linum_end}-1 ];

        # normalize number of blank lines to 1
        while (1) {
            last unless @section_lines;
            last if $section_lines[-1] =~ /\S/;
            pop @section_lines;
        }
        push @res, @section_lines, "\n";
    }

    join "", @res;
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
