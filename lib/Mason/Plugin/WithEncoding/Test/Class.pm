package Mason::Plugin::WithEncoding::Test::Class;

use utf8;
#use Test::Class::Most parent => ['Poet::Test::Class', 'Mason::Test::Class']; # yeah I know
use Test::Class::Most parent => 'Poet::Test::Class';
use Poet::Tools qw(dirname mkpath trim write_file);

sub mech {
    my $self = shift;
    my $poet = shift;
    my $mech = $self->SUPER::mech( env => $poet );
    @{ $mech->requests_redirectable } = ();
    return $mech;
}

sub add_comp {
    my ( $self, %params ) = @_;
    my $path = $params{path} or die "must pass path";
    my $src  = $params{src}  or die "must pass src";
    my $file = $params{poet}->comps_dir . $path;
    mkpath( dirname($file), 0, 0775 );  ## no critic (ProhibitLeadingZeros)
    write_file( $file, $src );
}

  
1;
