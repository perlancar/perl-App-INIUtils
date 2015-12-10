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
            in=>[
                'Config::INI::Reader',
                '',
                '',
                '',
                '',
            ],
        }],
        default => 'Config::INI::Reader',
        req     => 1,
        pos     => 0,
        cmdline_src => 'stdin_or_file',
        tags    => ['common'],
    },
);

1;
# ABSTRACT: INI utilities

=head1 SYNOPSIS

This distribution provides the following command-line utilities:

#INSERT_EXECS_LIST

The main feature of these utilities is tab completion.


=head1 SEE ALSO

L<App::IODUtils>

=cut
