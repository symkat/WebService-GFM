package WebService::GFM::Response;
use warnings;
use strict;
use base 'HTTP::Headers';
use base 'HTTP::Message';
use base 'HTTP::Response';

sub reply {
    my $class = shift;
    $class->{reply} = shift if @_;
    return $class->{reply};
}

1;
