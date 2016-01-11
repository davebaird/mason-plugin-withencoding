use 5.006;
use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Mason::Plugin::WithEncoding',
    license             => 'artistic_2',
    dist_author         => q{David R. Baird <dave@zerofive.co.uk >},
    dist_version_from   => 'lib/Mason/Plugin/WithEncoding.pm',
    release_status      => 'stable',
    configure_requires => {
        'Module::Build' => 0,
    },
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
        'Plack::Request::WithEncoding' => 0,
        Mason => 2.13,
        Poet => 0,
        'Mason::Plugin' => 0,
        Moose => 0,
        Encode => 0,
        'Try::Tiny' => 0,
    },
    add_to_cleanup     => [ 'Mason-Plugin-WithEncoding-*' ],
    create_makefile_pl => 'traditional',
);

$builder->create_build_script();
