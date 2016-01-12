package Mason::Plugin::WithEncoding::t::UTF8;

use utf8;

use Test::Class::Most parent => 'Mason::Plugin::WithEncoding::Test::Class';
use Test::Warnings qw(warnings);
use Capture::Tiny qw();
use Guard;
use Poet::Tools qw(dirname mkpath trim write_file);
use Encode qw(encode decode);

# Setup stolen from Poet::t::Run and Poet::t::PSGIHandler

# Test::Builder prints messages without turning on encoding for the print 
# filehandle, so we get warnings about wide characters for some of these tests. 
# Not sure how to silence them, but encoding these strings here is NOT correct. 
# Test::Harness (?) supplies the 'output' filehandle to Test::Builder so 
# maybe the problem is there. 
sub test_withencoding : Tests {
    my $self = shift;
    my $poet_conf = shift;
    
    my $conf_utf8 = {
        'layer'       => 'production',
        'server.port' => 9999,

        'mason.extra_plugins' => [qw(WithEncoding)],
        'server.load_modules' => ['Mason::Plugin::WithEncoding'],
        'server.encoding.request' => 'UTF-8',
        'server.encoding.response' => 'UTF-8',
        'server.default_content_type' => 'text/html; charset=UTF-8',
    };

    my $poet = $self->temp_env(conf => $conf_utf8);
    my $root_dir = $poet->root_dir;
    my $run_log  = "$root_dir/logs/run.log";
    
    if ( my $pid = fork() ) {
        # parent
        scope_guard { kill( 1, $pid ) };
        sleep(2);

        my $mech = $self->mech($poet);
        
        # Encode the content because it is leaving Perl (which uses its own 
        # internal character representation) and being sent to the system for 
        # storage. Plack::Request::WithEncoding will decode it again when 
        # we ask for it via WWW::Mechanize and Mason.
        
        #
        # Unescaping the query string doesn't produce love hearts, which I don't 
        # really understand, since this does:
        #
        # $ perl -MURI::Escape -e 'print uri_unescape("%E2%99%A5%E2%99%A5=%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5")."\n"'
        # $ ♥♥=♥♥♥♥♥♥♥
        #

 

        # Don't encode the path because, hmm, not sure. Because it 'just works' as-is.
        $self->add_comp(path => '/♥♥♥.mc',   src => encode('UTF-8', $self->content_for_tests('utf8')), poet => $poet);
        $self->add_comp(path => '/utf8.mc',  src => encode('UTF-8', $self->content_for_tests('utf8')), poet => $poet);
        $self->add_comp(path => '/plain.mc', src => encode('UTF-8', $self->content_for_tests('plain')), poet => $poet);
        $self->add_comp(path => '/dies.mc',  src => encode('UTF-8', $self->content_for_tests('dies')), poet => $poet);
        
        # utf8 config, utf8 content, utf8 url, utf8 query
        $mech->get_ok("http://127.0.0.1:9999/♥♥♥?♥♥=♥♥♥♥♥♥♥");
        # query string goes over wires as encoded ascii, so clients use url encoding to preserve information
        $mech->content_unlike(qr/QUERY STRING FROM REQ: ♥♥=♥♥♥♥♥♥/); 
        $mech->content_like(qr[QUERY STRING FROM REQ: \Q%E2%99%A5%E2%99%A5=%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5\E]);
        $mech->content_unlike(qr/QUERY STRING UNESCAPED: ♥♥=♥♥♥♥♥♥♥/);
        #warn $mech->content;
        $mech->content_like(qr/A QUICK BROWN FOX JUMPS OVER THE LAZY DOG/);
        $mech->content_unlike(qr/a quick brown fox jumps over the lazy dog/);
        $mech->content_like(qr/ΔΙΑΦΥΛΆΞΤΕ ΓΕΝΙΚΆ ΤΗ ΖΩΉ ΣΑΣ ΑΠΌ ΒΑΘΕΙΆ ΨΥΧΙΚΆ ΤΡΑΎΜΑΤΑ/);
        $mech->content_unlike(qr/διαφυλάξτε γενικά τη ζωή σας από βαθειά ψυχικά τραύματα/);

        # utf8 config, utf8 content, utf8 url, no query
        $mech->get_ok("http://127.0.0.1:9999/♥♥♥");
        $mech->content_like(qr/A QUICK BROWN FOX JUMPS OVER THE LAZY DOG/);
        $mech->content_unlike(qr/a quick brown fox jumps over the lazy dog/);
        $mech->content_like(qr/ΔΙΑΦΥΛΆΞΤΕ ΓΕΝΙΚΆ ΤΗ ΖΩΉ ΣΑΣ ΑΠΌ ΒΑΘΕΙΆ ΨΥΧΙΚΆ ΤΡΑΎΜΑΤΑ/);
        $mech->content_unlike(qr/διαφυλάξτε γενικά τη ζωή σας από βαθειά ψυχικά τραύματα/);
        
        # utf8 config, utf8 content, ascii url, utf8 query
        $mech->get_ok("http://127.0.0.1:9999/utf8?♥♥=♥♥♥♥♥♥♥");
        # query string goes over wires as encoded ascii, so clients use url encoding to preserve information
        $mech->content_unlike(qr/QUERY STRING FROM REQ: ♥♥=♥♥♥♥♥♥/); 
        $mech->content_like(qr[QUERY STRING FROM REQ: \Q%E2%99%A5%E2%99%A5=%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5%E2%99%A5\E]);
        $mech->content_unlike(qr/QUERY STRING UNESCAPED: ♥♥=♥♥♥♥♥♥♥/);
        #warn $mech->content;
        $mech->content_like(qr/A QUICK BROWN FOX JUMPS OVER THE LAZY DOG/);
        $mech->content_unlike(qr/a quick brown fox jumps over the lazy dog/);
        $mech->content_like(qr/ΔΙΑΦΥΛΆΞΤΕ ΓΕΝΙΚΆ ΤΗ ΖΩΉ ΣΑΣ ΑΠΌ ΒΑΘΕΙΆ ΨΥΧΙΚΆ ΤΡΑΎΜΑΤΑ/);
        $mech->content_unlike(qr/διαφυλάξτε γενικά τη ζωή σας από βαθειά ψυχικά τραύματα/);
        
        # utf8 config, utf8 content, ascii url, no query
        $mech->get_ok("http://127.0.0.1:9999/utf8");
        $mech->content_like(qr/A QUICK BROWN FOX JUMPS OVER THE LAZY DOG/);
        $mech->content_unlike(qr/a quick brown fox jumps over the lazy dog/);
        $mech->content_like(qr/ΔΙΑΦΥΛΆΞΤΕ ΓΕΝΙΚΆ ΤΗ ΖΩΉ ΣΑΣ ΑΠΌ ΒΑΘΕΙΆ ΨΥΧΙΚΆ ΤΡΑΎΜΑΤΑ/);
        $mech->content_unlike(qr/διαφυλάξτε γενικά τη ζωή σας από βαθειά ψυχικά τραύματα/);
        
        # utf8 config, plain content, plain url, no query
        $mech->get_ok("http://127.0.0.1:9999/plain");
        $mech->content_like(qr/LOREM IPSUM DOLOR SIT AMET/);
        $mech->content_unlike(qr/Lorem ipsum dolor sit amet/);

        # utf8 config, chokes on $.args->{♥} in the page, looks like a bug
        $mech->get("http://127.0.0.1:9999/dies");
        ok($mech->status == 500, 'UTF8 content bug');
        
        kill( 1, $pid );
        waitpid($pid, 0);
    }
    else {
        # child
        close STDOUT;
        close STDERR;
        exec( $poet->bin_path("run.pl > $run_log 2>&1") );
    }
}

1;
