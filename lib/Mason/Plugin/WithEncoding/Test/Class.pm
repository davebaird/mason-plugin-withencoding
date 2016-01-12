package Mason::Plugin::WithEncoding::Test::Class;

use utf8;

# http://www.effectiveperlprogramming.com/2011/07/fix-testbuilders-unicode-issue/
binmode Test::More->builder->output(),         ':encoding(UTF-8)';
binmode Test::More->builder->failure_output(), ':encoding(UTF-8)';

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
    mkpath( dirname($file), 0, '0775' );
    write_file( $file, $src );
}

sub content_for_tests {
    my ($self, $want) = @_;

    my $src_utf8 = <<UTF8;
% sub { uc(\$_[0]) } {{
a quick brown fox jumps over the lazy dog.

διαφυλάξτε γενικά τη ζωή σας από βαθειά ψυχικά τραύματα.
árvíztűrő tükörfúrógép.
dość gróźb fuzją, klnę, pych i małżeństw!
эх, чужак, общий съём цен шляп (юфть) – вдрызг!
kŕdeľ šťastných ďatľov učí pri ústí váhu mĺkveho koňa obhrýzať kôru a žrať čerstvé mäso.
zwölf boxkämpfer jagen viktor quer über den großen sylter deich.

% }}

QUERY STRING FROM REQ: <% \$m->req->query_string %>

% use URI::Escape;
QUERY STRING UNESCAPED: <% \$m->req->query_string %>

UTF8

    # I think if everything was running correctly, this wouldn't die:
    my $src_utf8_dies = <<UTF8;
<% \$.args->{♥} %>
UTF8

    my $src_plain = <<ASCII;
% sub { uc(\$_[0]) } {{

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ut ante
mollis, ultricies arcu ut, convallis libero. Fusce a felis sapien. Aliquam
aliquam felis ut justo aliquam, non sollicitudin tellus porta. Etiam
sollicitudin, mi eu vulputate sagittis, elit arcu molestie leo, eget finibus
tortor risus ut quam. Aenean id dolor eros. Vestibulum dictum, sem vitae
molestie feugiat, enim quam ultricies metus, quis dapibus sapien orci ut risus.

% }}

QUERY STRING FROM REQ: <% \$m->req->query_string %>

% use URI::Escape;
QUERY STRING UNESCAPED: <% uri_unescape(\$m->req->query_string) %>

ASCII

    return $src_utf8        if $want eq 'utf8';
    return $src_plain       if $want eq 'plain';
    return $src_utf8_dies   if $want eq 'dies';
    die "No content for '$want'";
}

1;
