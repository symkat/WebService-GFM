# NAME

WebService::GFM - A GFM-Service Markdown Client

# DESCRIPTION

WebService::GFM is a Perl client for the GFM-Service Markdown
API.  You can find information on the GFM-Service Markdown API
at [https://github.com/symkat/GFM-Service](https://github.com/symkat/GFM-Service).

By using the GFM-Service and WebService::GFM projects one can
use GitHub Flavored Markdown from within Perl applications.

# SYNOPSIS

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

# CONSTRUCTOR

Each constructor argument can be accessed after the object is created,
and set to new values.

my $endpoint = $gfm->endpoint  ; # Get Value
$gfm->endpoint( $new_endpoint ); # Set Value.

For `useragent` and `timeout` a new `LWP::Request` instance
will be built.  For all others, the options to send to the endpoint
will be rebuilt.  The options and `LWP::UserAgent` instance are
cached between `markdown` calls to allow faster use in persistently
run applications.

## endpoint

The `endpoint` takes the HTTP location for the API call.  If you have
GFM-Service running at http://markdown.mydomain.com:8085/ then you would
provide endpoint => "http://markdown.mydomain.com:8085/".

## timeout

For the `LWP::UserAgent`, how long to wait before giving up on the
HTTP request.

## useragent

For the `LWP::UserAgent`, the useragent string to send with the request.

Default: WebService::GFM/$VERSION

## no_intra_emphasis

When set to true, strings with _ between them will not generate
<em> tags.  Such that $my_random_scalar won't become 
$my<em>random</em>scalar.

Default: False

## tables

When set to true, Markdown style tables will be parsed.

Default: False

## fenced_code_blocks

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

## autolink

When set to true, create links even when they are not within
<>.  This will work for email addresses, http, https and ftp
protocols, and for domain names starting with www and leaving
out the http.

Default: False

## strikethrough

When set to true, two tildas around a word strike the word.

Example: This is ~~weird~~ great!

Default: False

## lax_html_blocks

When set to true, HTML blocks do not require being surrounded
by an empty line to be treated as HTML.

Default: False

## space_after_headers

When set to true a space is always required between the hash and
header text.

Example: #this is invalid when enabled.

Default: False

## superscript

When set to true, ^ begins superscript, values can be enclosed in
parenthesis.

Example: This is the 3^(rd) time this week.

Default: False

# METHODS

## markdown

The `markdown` method takes the document to markdown as a single
scalar value, and returns a `WebService::GFM::Response` object.  The
API response is stored in `reply`.  `WebService::GFM::Response` is a
subclass of the LWP Response Object.

# AUTHOR

SymKat _<symkat@symkat.com>_ ( Blog: [http://symkat.com/](http://symkat.com/) )

## CONTRIBUTORS

# COPYRIGHT

Copyright (c) 2012 the WebService::GFM ["AUTHOR"](#AUTHOR) and ["CONTRIBUTORS"](#CONTRIBUTORS) 
as listed above.

# LICENSE 

This library is free software and may be distributed under the 
same terms as perl itself.

## AVAILABILITY

The most current version of WebService::GFM can be found at 
[https://github.com/symkat/WebService-GFM](https://github.com/symkat/WebService-GFM)