package WebService::GFM;
use warnings;
use strict;
use LWP::UserAgent;
use HTTP::Request;
use JSON qw( decode_json encode_json );
use WebService::GFM::Response;

use Data::Dumper;

our $VERSION = '0.000001'; # 0.0.1
$VERSION = eval $VERSION;

my @accessors = qw(
    _ua timeout useragent endpoint _options
    document no_intra_emphasis tables fenced_code_blocks autolink 
    strikethrough lax_html_blocks space_after_headers superscript
);

my @fields = qw(
    no_intra_emphasis tables fenced_code_blocks autolink 
    strikethrough lax_html_blocks space_after_headers superscript
);

# Accessor building

for my $method ( @accessors ) {
    my $accessor = sub {
        my $self = shift;
        if ( @_ ) {
            $self->{$method} = shift if @_;
            $self->after($method);
        }
        return $self->{$method};
    };
    {
        no strict 'refs';
        *$method = $accessor;
    }
}


sub new {
    my ( $class, $args ) = @_;
    
    my $self = bless {
        timeout => 60,
        useragent => "WebService::GFM/$VERSION",
    }, $class;

    for my $accessor ( @accessors ) {
        if ( exists $args->{$accessor} ) {
            $self->{$accessor} = delete $args->{$accessor};
        }
    }
    die "Unknown arguments to the constructor: " . join( " ", keys %$args )
        if keys( %$args );

    $self->build_ua;
    $self->set_options;

    return $self;
}

sub after {
    my ( $self, $method ) = @_;
    $self->set_options if grep { $_ eq $method } @fields;
    $self->build_ua if grep { $_ eq $method } qw( useragent timeout );
}

sub build_ua {
    my ( $self ) = @_;

    $self->{_ua} = LWP::UserAgent->new( 
        timeout => $self->timeout, 
        user_agent => $self->useragent 
    );
    return $self;
}

sub set_options {
    my ( $self ) = @_;
    
    # Construct a hash based on the accessors in @fields that
    # are enabled.
    my %options = map { $self->$_ ?  ( $_ => 1 ) : () } @fields;
    $self->_options(  \%options );
}

sub markdown {
    my ( $self, $document ) = @_;

    my %json = ( document => $document, %{$self->_options} );

    my $req = HTTP::Request->new( 'POST' => $self->endpoint );
    $req->content( encode_json(\%json ) );
    $req->content_type( 'application/json' );

    my $res = $self->_ua->request( $req );
    bless $res, 'WebService::GFM::Response';

    $res->reply( decode_json( $res->content ) );

    return $res;
}

1;

=head1 NAME

WebService::GFM - A GFM-Service Markdown Client

=head1 DESCRIPTION

WebService::GFM is a Perl client for the GFM-Service Markdown
API.  You can find information on the GFM-Service Markdown API
at L<https://github.com/symkat/GFM-Service>.

By using the GFM-Service and WebService::GFM projects one can
use GitHub Flavored Markdown from within Perl applications.

=head1 SYNOPSIS

    #!/usr/bin/perl
    use warnings;
    use strict;
    use WebService::GFM;

    my $gfm = WebService::GFM->new({
        endpoint            => "http://markdown.symkat.com/",
        fenced_code_blocks  => 1,
        autolink            => 1,
        tables              => 1,
    });

    my $response = $gfm->markdown( "# Hello World" );

    if ( $response->is_success ) {
        print $response->reply->{document};
    }

=head1 CONSTRUCTOR

Each constructor argument can be accessed after the object is created,
and set to new values.

my $endpoint = $gfm->endpoint  ; # Get Value
$gfm->endpoint( $new_endpoint ); # Set Value.

For C<useragent> and C<timeout> a new C<LWP::Request> instance
will be built.  For all others, the options to send to the endpoint
will be rebuilt.  The options and C<LWP::UserAgent> instance are
cached between C<markdown> calls to allow faster use in persistently
run applications.

=head2 endpoint

The C<endpoint> takes the HTTP location for the API call.  If you have
GFM-Service running at http://markdown.mydomain.com:8085/ then you would
provide endpoint => "http://markdown.mydomain.com:8085/".

=head2 timeout

For the C<LWP::UserAgent>, how long to wait before giving up on the
HTTP request.

=head2 useragent

For the C<LWP::UserAgent>, the useragent string to send with the request.

Default: WebService::GFM/$VERSION

=head2 no_intra_emphasis

When set to true, strings with _ between them will not generate
<em> tags.  Such that $my_random_scalar won't become 
$my<em>random</em>scalar.

Default: False

=head2 tables

When set to true, Markdown style tables will be parsed.

Default: False

=head2 fenced_code_blocks

When set to true, blocks begining with three backticks or tildas will
be treated as a codeblock without having to indent.  Optionally, the
language may be specified to enable syntax hilighting with Albino.

Example:
    ```perl
    #!/usr/bin/perl
    use warnings;
    use strict;

    print "Hello World!\n";
    ```

Default: False

=head2 autolink

When set to true, create links even when they are not within
<>.  This will work for email addresses, http, https and ftp
protocols, and for domain names starting with www and leaving
out the http.

Default: False

=head2 strikethrough

When set to true, two tildas around a word strike the word.

Example: This is ~~weird~~ great!

Default: False

=head2 lax_html_blocks

When set to true, HTML blocks do not require being surrounded
by an empty line to be treated as HTML.

Default: False

=head2 space_after_headers

When set to true a space is always required between the hash and
header text.

Example: #this is invalid when enabled.

Default: False

=head2 superscript

When set to true, ^ begins superscript, values can be enclosed in
parenthesis.

Example: This is the 3^(rd) time this week.

Default: False

=head1 METHODS

=head2 markdown

The C<markdown> method takes the document to markdown as a single
scalar value, and returns a C<WebService::GFM::Response> object.  The
API response is stored in C<reply>.  C<WebService::GFM::Response> is a
subclass of the LWP Response Object.

=head1 AUTHOR

SymKat I<E<lt>symkat@symkat.comE<gt>> ( Blog: L<http://symkat.com/> )

=head2 CONTRIBUTORS

=head1 COPYRIGHT

Copyright (c) 2012 the WebService::GFM L</AUTHOR> and L</CONTRIBUTORS> 
as listed above.

=head1 LICENSE 

This library is free software and may be distributed under the 
same terms as perl itself.

=head2 AVAILABILITY

The most current version of WebService::GFM can be found at 
L<https://github.com/symkat/WebService-GFM>
