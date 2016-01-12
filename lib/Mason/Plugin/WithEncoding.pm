package Mason::Plugin::WithEncoding;

use Moose;
use Poet qw($poet $conf);
use Mason 2.13 (); 

with 'Mason::Plugin';

=head1 NAME

Mason::Plugin::WithEncoding - add encoding support to Poet/Mason apps


=head1 SYNOPSIS

    In your Poet config file:
    
        # This is important or the first (and *only* the first) request will   
        # not use Plack::Request::WithEncoding
        server.load_modules:
            - Mason::Plugin::WithEncoding    
    
        mason:
          extra_plugins:
            - WithEncoding
            
        server.encoding.request: UTF-8
        server.encoding.response: UTF-8
        server.default_content_type: text/html; charset=UTF-8


=head1 DESCRIPTION

To decode the request, the plugin loads L<Plack::Request::WithEncoding> and 
configures it with the encoding specified in C<server.encoding.request>. If no 
such setting is found, the request is not decoded. This matches the default 
behaviour of Poet/Mason, but is different from L<Plack::Request::WithEncoding>, 
(which would normally default to UTF-8).

Output generated by your Mason templates is encoded according to the setting 
in C<server.encoding.response>. If no such setting is found, the response is not 
encoded. This is the default behaviour of Poet/Mason. 

The content-type default header is set according to C<server.default_content_type>. 
If no such setting is found, the default header is C<text/html>, as in the default 
Poet/Mason setup. This tells the client what encoding to use when decoding our 
content, and also (AFAIK) tells the client what encoding to use when sending us 
data. 

Output sent through C<send_json> is also encoded and the content-type header 
set accordingly.
        
=head2 Caveat

This plugin only works inside a L<Poet> environment.

=head2 Some background

    http://stackoverflow.com/questions/27806684/mason2-wrong-utf8-encoding-with-the-go-method
    http://stackoverflow.com/questions/5858596/how-to-make-mason2-utf-8-clean
    https://www.mail-archive.com/mason-users@lists.sourceforge.net/msg03450.html

=head2 TODO 

Check the FillInForm filter, maybe convert to use L<HTML::FillInForm::ForceUTF8>.

=cut

#    So in short:
#    If someone is able write an UTF8 __PLUGIN__ for Mason2, need to do 5 things:
#    
#    1.) add "use utf8;" into every obj. file (this should be done by
#            plugin regardless of the next)
#    2.) allow adding additional pradmas into the obj source - this is done already!
#    3.) encode everything what going from Mason ---to---> Plack
#    4.) decode everything what coming from Pack --to--> Mason
#    5.) Add UTF8 safe FillInForm into Filters (and check other filters)
 

# This sidesteps Poet::Plack::Request, but - at the moment (Jan 2016) - that's 
# just an empty subclass of Plack::Request
BEGIN {
    my $app_name = $poet->app_name;
    my $enc = $conf->get('server.encoding.request', undef);
    
    eval <<EVAL;                          ## no critic (ProhibitStringyEval)
package ${app_name}::Plack::Request;
use parent ('Plack::Request::WithEncoding', 'Poet::Plack::Request');

sub new {
    my \$self = shift->SUPER::new(\@_);
    \$self->env->{'plack.request.withencoding.encoding'} = '$enc';
    return \$self;
}
EVAL

    die $@ if $@;
}

1;

package Mason::Plugin::WithEncoding::Request;

use Mason::PluginRole;
use Poet qw($conf);
use Encode qw(encode decode);
use Try::Tiny;

around 'run' => sub { 
    my $orig = shift;
    my $self = shift;
    
    my $enc = $conf->get( 'server.encoding.response' => undef );
    
    $self->res->content_type( $conf->get( 'server.default_content_type' => undef ) )
      if !$self->res->content_type();    
      
    my $result = $self->$orig(@_); # this call loads content into the Plack::Response object
    
    my $content = $self->res->content;
    my $bytes = encode($enc, $content);
    $self->res->content($bytes);    
    
    return $result; # will be discarded 
};

# we just need to update the content-type header
around 'send_json' => sub {
    my $self = shift;
    my $orig = shift;
    my $data = shift; 
    
    my $enc = $conf->get( 'server.encoding.response' => undef );
    
    try { 
        $self->$orig($data);            # aborts
    }
    catch {
        my $err = $_;
        if ($self->aborted($err)) {     # expected
            $self->res->content_type("application/json; charset=$enc") if $enc; # it's already set, but without charset
            $err->rethrow;
        }
        else {
            die $err;                   # unexpected
        }
    };
};

1;

package Mason::Plugin::WithEncoding::Compilation;

use Mason::PluginRole;

# None of this is required for the encode/decode cycle, but it's good stuff 
# to have for the encoding-aware developer.

around 'output_class_header' => sub {
    my $orig = shift;
    my $self = shift;
    
    return join "\n", $self->$orig, 
        q/use utf8; 
          use 5.012; 
          use encoding::warnings;
          use Encode qw(encode decode);
          /;
};

1;


=head1 AUTHOR

David R. Baird, C<< <dave at zerofive.co.uk > >>

=head1 BUGS

Please report any bugs or feature requests through the web interface at
L<https://github.com/davebaird/mason-plugin-withencoding>. I will be notified,
and then you'll automatically be notified of progress on your bug as I make
changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mason::Plugin::WithEncoding


You can also look for information at:

=over 4

=item * Github (report bugs here)

L<https://github.com/davebaird/mason-plugin-withencoding>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mason-Plugin-WithEncoding>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mason-Plugin-WithEncoding>

=item * Search CPAN

L<http://search.cpan.org/dist/Mason-Plugin-WithEncoding/>

=back

=head1 LICENSE AND COPYRIGHT

See the LICENSE file included with this distribution.


=cut

1; # End of Mason::Plugin::WithEncoding
