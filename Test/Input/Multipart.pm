#
# $Id: Multipart.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Multipart.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Input::Multipart;

#
# POST input data to be encoded with "multipart/form-data".
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
	$self->{boundary} = "-------------cgi-test--------------" .
		int(rand(1 << 31)) . '-' . int(rand(1 << 31));
	return DVAL $self;
}

#
# Attribute access
#

sub boundary		{ $_[0]->{boundary} }

#
# Defined interface
#

sub mime_type		{ "multipart/form-data; boundary=" . $_[0]->{boundary} }

#
# ->_build_data
#
# Rebuild data buffer from input fields.
#
sub _build_data {
	DFEATURE my $f_;
	my $self = shift;

	my $CRLF = "\015\012";
	my $data = '';
	my $fmt = 'Content-Disposition: form-data; name="%s"';
	my $boundary = "--" . $self->boundary;	# With extra "--" per MIME specs

	# XXX field name encoding of special chars?
	# XXX does not escape "" in filenames

	foreach my $tuple (@{$self->_fields}) {
		my ($name, $value) = @$tuple;
		$data .= $boundary . $CRLF;
		$data .= sprintf($fmt, $name) . $CRLF . $CRLF;
		$data .= $value . $CRLF;
	}

	foreach my $tuple (@{$self->_files}) {
		my ($name, $value, $content) = @$tuple;
		$data .= $boundary . $CRLF;
		$data .= sprintf($fmt, $name);
		$data .= sprintf('; filename="%s"', $value). $CRLF;
		$data .= "Content-Type: application/octet-stream" . $CRLF . $CRLF;
		if (defined $content) {
			$data .= $content;
		} else {
			local *FILE;
			if (open(FILE, $value)) {		# Might not exist, but that's OK
				binmode FILE;
				local $_;
				while (<FILE>) {
					$data .= $_;
				}
				close FILE;
			}
		}
	}

	$data .= $boundary . $CRLF;

	return DVAL $data;
}

1;

=head1 NAME

CGI::Test::Input::Multipart - POST input encoded as multipart/form-data

=head1 SYNOPSIS

 # Inherits from CGI::Test::Input
 require CGI::Test::Input::Multipart;

 my $input = CGI::Test::Input::Multipart->make();

=head1 DESCRIPTION

This class represents the input for HTTP POST requests, encoded
as C<multipart/form-data>.

Please see L<CGI::Test::Input> for interface details.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Input(3).

=cut

