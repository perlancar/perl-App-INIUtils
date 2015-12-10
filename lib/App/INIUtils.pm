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
);

our %arg_parser = (
    parser => {
        summary => 'Parser to use',
        schema  => ['str*', {
            in => [
                'Config::INI::Reader',
                'Config::IniFiles',
            ],
        }],
        default => 'Config::INI::Reader',
        tags    => ['common'],
    },
);

sub _parse_str {
    my ($ini, $parser) = @_;

    if ($parser eq 'Config::INI::Reader') {
        require Config::INI::Reader;
        return Config::INI::Reader->read_string($ini);
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
