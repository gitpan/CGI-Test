#
# $Id: Real.pm,v 0.1 2001/03/31 10:54:03 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Real.pm,v $
# Revision 0.1  2001/03/31 10:54:03  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Page::Real;

#
# An abstract interface to a real page, which is the result of a valid output
# and not an HTTP error.  The concrete representation is defined by heirs,
# depending on the Content-Type.
#

use Carp::Datum;
use Getargs::Long;
use Log::Agent;

require CGI::Test::Page;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Page);

#
# ->make
#
# Creation routine
#
sub make { logconfess "deferred" }

#
# Attribute access
#

sub raw_content		{ $_[0]->{raw_content} }
sub uri				{ $_[0]->{uri} }

sub raw_content_ref	{ \$_[0]->{raw_content} }

#
# ->_init
#
# Initialize common attributes
#
sub _init {
	DFEATURE my $f_;
	my $self = shift;
	my ($server, $file, $ctype, $user, $uri) =
		cxgetargs(@_, { -strict => 0, -extra => 0 },
			-server			=> 'CGI::Test',		# XXX may be extended one day
			-file			=> 's',
			-content_type	=> 's',
			-user			=> undef,
			-uri			=> 'URI',
		);
	$self->{server} = $server;
	$self->{content_type} = $ctype;
	$self->{user} = $user;
	$self->{uri} = $uri;
	$self->_read_raw_content($file);
	return DVOID;
}

#
# ->_read_raw_content
#
# Read file content verbatim into `raw_content', skipping header.
#
# Even in the case of an HTML content, reading the whole thing into memory
# as a big happy string means we can issue regexp queries.
#
sub _read_raw_content {
	DFEATURE my $f_;
	my $self = shift;
	my ($file) = @_;

	local *FILE;
	open(FILE, $file) || logdie "can't open $file: $!";
	my $size = -s FILE;

	$self->{raw_content} = ' ' x -s(FILE);	# Pre-extend buffer

	local $_;
	while (<FILE>) {						# Skip header
		last if /^\r?$/;
	}

	local $/ = undef;						# Will slurp remaining
	$self->{raw_content} = <FILE>;
	close FILE;

	return DVOID;
}

1;

=head1 NAME

CGI::Test::Page::Real - Abstract representation of a real page

=head1 SYNOPSIS

 # Inherits from CGI::Test::Page
 # $page holds a CGI::Test::Page::Real object

 use CGI::Test;

 ok 1, $page->raw_content =~ /test is ok/;
 ok 2, $page->uri->scheme eq "http";
 ok 3, $page->content_type !~ /html/;

=head1 DESCRIPTION

This class is the representation of a real page, i.e. something physically
returned by the server and which is not an error.

=head1 INTERFACE

The interface is the same as the one described in L<CGI::Test::Page>, with
the following additions:

=over 4

=item C<raw_content>

Returns the raw content of the page, as a string.

=item C<raw_content_ref>

Returns a reference to the raw content of the page, to avoid making yet
another copy.

=item C<uri>

The URI object, identifying the page we requested.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Page(3), CGI::Test::Page::HTML(3), CGI::Test::Page::Other(3),
CGI::Test::Page::Text(3), URI(3).

=cut

