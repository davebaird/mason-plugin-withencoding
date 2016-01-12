package Mason::Plugin::WithEncoding::t::UTF8;

use utf8;

use Test::Class::Most parent => 'Mason::Plugin::WithEncoding::Test::Class';
use Capture::Tiny qw();
use Guard;
use Poet::Tools qw(dirname mkpath trim write_file);

# Setup stolen from Poet::t::Run and Poet::t::PSGIHandler

my $conf_utf8 = {
        layer                 => 'production',
        'server.port' => 9999,

        'mason.extra_plugins' => [qw(WithEncoding)],
        'server.load_modules' => ['Mason::Plugin::WithEncoding'],
        'server.encoding.request' => 'UTF-8',
        'server.encoding.response' => 'UTF-8',
        'server.default_content_type' => 'text/html; charset=UTF-8',
    };
    
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
UTF8

# I think if everything was running correctly, this wouldn't die:
my $src_utf8_dies = <<UTF8;
<% \$.args->{♥} %>
UTF8

my $src = <<ASCII;
% sub { uc(\$_[0]) } {{
a quick brown fox jumps over the lazy dog.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Praesent ut ante
mollis, ultricies arcu ut, convallis libero. Fusce a felis sapien. Aliquam
aliquam felis ut justo aliquam, non sollicitudin tellus porta. Etiam
sollicitudin, mi eu vulputate sagittis, elit arcu molestie leo, eget finibus
tortor risus ut quam. Aenean id dolor eros. Vestibulum dictum, sem vitae
molestie feugiat, enim quam ultricies metus, quis dapibus sapien orci ut risus.

% }}
ASCII

my $comp_path = '/comp.mc';
my $comp_path_utf8 = '/♥♥♥.mc';
my $qs = '?foo=bar';
my $qs_utf8 = '?♥=♥♥';

sub test_utf8 : Tests {
    my $self = shift;
    my $poet = $self->temp_env( conf => $conf_utf8 );
    my $root_dir = $poet->root_dir;
    my $run_log  = "$root_dir/logs/run.log";
    
    if ( my $pid = fork() ) {
        scope_guard { kill( 1, $pid ) };
        sleep(2);

        my $mech = $self->mech($poet);
        
        $mech->get_ok('http://127.0.0.1:9999/');
        $mech->content_like(qr/Welcome to Poet/);
        $mech->content_like(qr/Environment root.*\Q$root_dir\E/);
        
        $self->add_comp(path => $comp_path, src => $src, poet => $poet);
        
        $mech->get_ok("http://127.0.0.1:9999/comp");
        #$mech->content_like(qr/Welcome to Poet/);
        $mech->content_like(qr/LOREM IPSUM DOLOR SIT AMET/);
        $mech->content_unlike(qr/Lorem ipsum dolor sit amet/);
        
        use Encode qw(encode decode);
        # We encode the content because it is leaving Perl (which uses its own 
        # internal character representation) and being sent to the system for 
        # storage. Plack::Request::WithEncoding will decode it again when 
        # we ask for it via WWW::Mechanize and Mason.
        
        # We don't encode the path because, hmm, not sure. Because it 'just works' as-is.
        
        #$self->add_comp(path => encode('UTF-8', $comp_path_utf8), src => encode('UTF-8', $src_utf8), poet => $poet);
        $self->add_comp(path => $comp_path_utf8, src => encode('UTF-8', $src_utf8), poet => $poet);
        
        # Test::Builder prints messages without turning on encoding for the print 
        # filehandle, so we get warnings about wide characters for each of these tests. 
        # Not sure how to silence them, but encoding these strings here is NOT correct. 
        # Test::Harness (or whatever we are using) supplies the 'output' filehandle 
        # to Test::Builder so maybe the problem is there. 

        #$mech->get_ok(encode('UTF-8', "http://127.0.0.1:9999/♥♥♥"));
        $mech->get_ok("http://127.0.0.1:9999/♥♥♥");
        
        $mech->content_like(qr/A QUICK BROWN FOX JUMPS OVER THE LAZY DOG/);
        $mech->content_unlike(qr/a quick brown fox jumps over the lazy dog/);
        
        $mech->content_like(qr/ΔΙΑΦΥΛΆΞΤΕ ΓΕΝΙΚΆ ΤΗ ΖΩΉ ΣΑΣ ΑΠΌ ΒΑΘΕΙΆ ΨΥΧΙΚΆ ΤΡΑΎΜΑΤΑ/);
        $mech->content_unlike(qr/διαφυλάξτε γενικά τη ζωή σας από βαθειά ψυχικά τραύματα/);
        #my $caps = encode('UTF-8', 'ΔΙΑΦΥΛΆΞΤΕ ΓΕΝΙΚΆ ΤΗ ΖΩΉ ΣΑΣ ΑΠΌ ΒΑΘΕΙΆ ΨΥΧΙΚΆ ΤΡΑΎΜΑΤΑ');
        #my $low =  encode('UTF-8', 'διαφυλάξτε γενικά τη ζωή σας από βαθειά ψυχικά τραύματα');
        #$mech->content_like(qr/$caps/);
        #$mech->content_unlike(qr/$low/);

        
=pod

use File::Find;
find(\&files, $root_dir);

use File::Slurp; 
print STDERR "\n\n@@@ index.mc:   \n";
print STDERR read_file("$root_dir/comps/index.mc");
print STDERR "\n\n@@@ Base.mc:   \n";
print STDERR read_file("$root_dir/comps/Base.mc");
print STDERR "\n\n@@@ comp.mc:   \n";
print STDERR read_file("$root_dir/comps/comp.mc");

=cut
        #unlink( glob( $poet->comps_path("*.mc") ) );

        
    }
    else {
        close STDOUT;
        close STDERR;
        exec( $poet->bin_path("run.pl > $run_log 2>&1") );
    }
}


sub files {
  if( -d ){
     print STDERR "Directory $File::Find::name\n";
  } else {
    print STDERR " $File::Find::name\n";
  }

}
  


1;
