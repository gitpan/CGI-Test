#
# $Id: Page.pm,v 0.1 2001/03/31 10:54:03 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Page.pm,v $
# Revision 0.1  2001/03/31 10:54:03  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Page;

#
# An abstract representation of a page, returned by an HTTP request.
# The page can be an error, or a real page, each with its own class hierarchy.
#

use Carp::Datum;
use Getargs::Long;
use Log::Agent;

#
# ->make
#
# Creation routine
#
sub make { logconfess "deferred" }

#
# Common attribute access
#

sub content_type	{ $_[0]->{content_type} }
sub user			{ $_[0]->{user} }
sub server			{ $_[0]->{server} }

#
# Queries
#

sub error_code	{ 0 }			# Error code (0 = OK)
sub is_error	{ 0 }			# True if page indicates HTTP error
sub form_count	{ 0 }
sub is_ok       { !$_[0]->is_error }

#
# ->forms
#
# Returns list ref of CGI::Test::Form objects, one per <FORM></FORM> in the
# document.  The order is the same as the one in the raw document.
#
# Meant to be redefined in CGI::Test::Page::HTML.
#
sub forms {
	DFEATURE my $f_;
	my $self = shift;
	return DVAL [];
}

#
# ->delete
#
# Done with this page, cleanup by breaking circular refs.
#
sub delete {
	DFEATURE my $f_;
	my $self = shift;
	$self->{server} = undef;
	return DVOID;
}

1;

=head1 NAME

CGI::Test::Page - Abstract represention of an HTTP reply content

=head1 SYNOPSIS

 # Deferred class, only heirs can be created
 # $page holds a CGI::Test::Page object

 use CGI::Test;

 ok 1, $page->is_ok;
 ok 2, $page->user ne '';    # authenticated access

 my $ctype = $page->content_type;
 ok 3, $ctype eq "text/plain";

 $page->delete;

=head1 DESCRIPTION

The C<CGI::Test::Page> class is deferred.  It is an abstract representation
of an HTTP reply content, which would be displayed on a browser, as a page.
It does not necessarily hold HTML content.

Here is an outline of the class hierarchy tree, with the leading C<CGI::Test::>
string stripped for readability, and a trailing C<*> indicating deferred
clases:

    Page*
      Page::Error
      Page::Real*
        Page::HTML
        Page::Other
        Page::Text

Those classes are constructed as needed by C<CGI::Test>.  You must always
call I<delete> on them to break the circular references if you care about
reclaiming unused memory.

=head1 INTERFACE

This is the interface defined at the C<CGI::Test::Page> level.
Each subclass may add further specific features, but the following is
available to the whole hierarchy:

=over 4

=item C<content_type>

The MIME content type.

=item C<delete>

Breaks circular references to allow proper reclaiming of unused memory.
Must be the last thing to call on the object before forgetting about it.

=item C<error_code>

The error code.  Will be 0 to mean OK, but otherwise HTTP error codes
are used, as described by L<HTTP::Status>.

=item C<forms>

Returns a list reference containing all the CGI forms on the page,
as C<CGI::Test::Form> objects.  Will be an empty list for anything
but C<CGI::Test::Page::HTML>, naturally.

=item C<form_count>

The amount of forms held in the C<forms> list.

=item C<is_error>

Returns I<true> when the page indicates an HTTP error.

=item C<is_ok>

Returns I<true> when the page is not the result of an HTTP error.

=item C<server>

Returns the server object that returned the page.  Currently, this is
the C<CGI::Test> object, but it might change one day.  In any case, this
is the place where GET/POST requests may be addresed.

=item C<user>

The authenticated user that requested this page, or C<undef> if no
authentication was made.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Page::Error(3), CGI::Test::Page::Real(3).

=cut

