#
# $Id: URL.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: URL.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Input::URL;

#
# POST input data to be encoded with "application/x-www-form-urlencoded".
#

require CGI::Test::Input;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Input);

use Carp::Datum;
use Log::Agent;

#
# ->make
#
# Creation routine
#
sub make {
	DFEATURE my $f_;
	my $self = bless {}, shift;
	$self->_init;
	return DVAL $self;
}

#
# Defined interface
#

sub mime_type		{ "application/x-www-form-urlencoded" }

#
# ->_build_data
#
# Rebuild data buffer from input fields.
#
sub _build_data {
	DFEATURE my $f_;
	my $self = shift;

	DREQUIRE $self->_stale;

	#
	# Note that file uploading fields get handled as any other field, meaning
	# only the file path will be transmitted.
	#

	my $data = '';

	# XXX field name encoding of special chars is the same as data?

	foreach my $tuple (@{$self->_fields}, @{$self->_files}) {
		my ($name, $value) = @$tuple;
		$value =~ s/([^a-zA-Z0-9_. -])/uc sprintf("%%%02x",ord($1))/eg;
		$value =~ s/ /+/g;
		$name =~ s/([^a-zA-Z0-9_.-])/uc sprintf("%%%02x",ord($1))/eg;
		$data .= '&' if length $data;
		$data .= $name . '=' . $value;
	}

	return DVAL $data;
}

1;

=head1 NAME

CGI::Test::Input::URL - POST input encoded as application/x-www-form-urlencoded

=head1 SYNOPSIS

 # Inherits from CGI::Test::Input
 require CGI::Test::Input::URL;

 my $input = CGI::Test::Input::URL->make();

=head1 DESCRIPTION

This class represents the input for HTTP POST requests, encoded
as C<application/x-www-form-urlencoded>.

Please see L<CGI::Test::Input> for interface details.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Input(3).

=cut

