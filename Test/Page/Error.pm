#
# $Id: Error.pm,v 0.1 2001/03/31 10:54:03 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Error.pm,v $
# Revision 0.1  2001/03/31 10:54:03  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Page::Error;

#
# A reply to an HTTP request resulted in an error.
#

use Carp::Datum;
use Getargs::Long;

require CGI::Test::Page;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Page);

#
# ->make
#
# Creation routine
#
sub make {
	DFEATURE my $f_;
	my $self = bless {}, shift;
	my ($errcode, $server) = @_;
	$self->{error_code} = $errcode;
	$self->{server} = $server;
	return DVAL $self;
}

#
# Attribute access
#

sub error_code	{ $_[0]->{error_code} }		# redefined as attribute

#
# Redefined features
#

sub is_error		{ 1 }
sub content_type	{ "text/html" }

1;

=head1 NAME

CGI::Test::Page::Error - An HTTP error page

=head1 SYNOPSIS

 # Inherits from CGI::Test::Page

=head1 DESCRIPTION

This class represents an HTTP error page.
Its interface is the same as the one described in L<CGI::Test::Page>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Page(3), CGI::Test::Page::Real(3).

=cut

