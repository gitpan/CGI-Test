#
# $Id: Input.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Input.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Input;

#
# Abstract representation of the POST input data, which is a list of incoming
# parameters that can be encoded differently.
#

use Carp::Datum;
use Log::Agent;

#
# ->make
#
# Creation routine
#
sub make {
	logconfess "deferred";
}

#
# ->_init
#
# Initialization of common attributes
#
sub _init {
	DFEATURE my $f_;
	my $self = shift;
	$self->{stale} = 0;
	$self->{fields} = [];		# list of [name, value]
	$self->{files} = [];		# list of [name, value, content or undef]
	$self->{length} = 0;
	$self->{data} = '';
	return DVOID;
}

#
# Attribute access
#

sub _stale		{ $_[0]->{stale} }
sub _fields		{ $_[0]->{fields} }
sub _files		{ $_[0]->{files} }
sub length		{ $_[0]->_refresh if $_[0]->_stale; $_[0]->{length} }
sub data		{ $_[0]->_refresh if $_[0]->_stale; $_[0]->{data} }

#
# ->add_widget
#
# Add new input widget.
#
# This routine is called to build input data for POST requests issued in
# response to a submit button being pressed.
#
sub add_widget {
	DFEATURE my $f_;
	my $self = shift;
	my ($w) = @_;

	DREQUIRE ref $w && $w->isa("CGI::Test::Form::Widget");

	#
	# Appart from the fact that file widgets get inserted in a dedicated list,
	# the processing here is the same.  The 3rd value of the entry for files
	# will be undefined, meaning the file will be read at a later time, when
	# the input data is built.
	#

	my @tuples = $w->submit_tuples;
	my $array = $w->is_file ? $self->_files : $self->_fields;

	while (my ($name, $value) = splice @tuples, 0, 2) {
		$value = '' unless defined $value;
		push @$array, [$name, $value];
	}

	$self->{stale} = 1;

	return DVOID;
}

#
# ->add_field
#
# Add a new name/value pair to the input data.
#
# This routine is meant for manual input data building.
#
sub add_field {
	DFEATURE my $f_;
	my $self = shift;
	my ($name, $value) = @_;

	$value = '' unless defined $value;
	push @{$self->_fields}, [$name, $value];
	$self->{stale} = 1;

	return DVOID;
}

#
# ->add_file
#
# Add a new upload-file information to the input data.
# The actual reading of the file is deferred up to the moment where we
# need to build the input data.
#
# This routine is meant for manual input data building.
#
sub add_file {
	DFEATURE my $f_;
	my $self = shift;
	my ($name, $value) = @_;

	$value = '' unless defined $value;
	push @{$self->_files}, [$name, $value];
	$self->{stale} = 1;

	return DVOID;
}

#
# ->add_file_now
#
# Add a new upload-file information to the input data.
# The file is read immediately, and can be disposed of once we return.
#
# This routine is meant for manual input data building.
#
sub add_file_now {
	DFEATURE my $f_;
	my $self = shift;
	my ($name, $value) = @_;

	VERIFY -r $value, "readable file '$value'";

	local *FILE;
	open(FILE, $value);
	binmode FILE;

	local $_;
	my $content = '';

	while (<FILE>) {
		$content .= $_;
	}
	close FILE;

	push @{$self->_files}, [$name, $value, $content];
	$self->{stale} = 1;

	return DVOID;
}

#
# Interface to be implemented by heirs
#

sub mime_type		{ logconfess "deferred" }
sub _build_data		{ logconfess "deferred" }

#
# Internal routines
#

#
# ->_refresh
#
# Recomputes `data' and `length' attributes when stale
#
sub _refresh {
	DFEATURE my $f_;
	my $self = shift;

	DREQUIRE $self->_stale;				# internal pre-condition

	my $data = $self->_build_data;		# deferred

	$self->{data} = $data;
	$self->{length} = CORE::length $data;
	$self->{stale} = 0;

	DENSURE !$self->_stale;

	return DVOID;
}

1;

=head1 NAME

CGI::Test::Input - Abstract representation of POST input

=head1 SYNOPSIS

 # Deferred class, only heirs can be created
 # $input holds a CGI::Test::Input object

 $input->add_widget($w);                     # done internally for you

 $input->add_field("name", "value");         # manual input construction
 $input->add_file("name", "path");           # deferred reading
 $input->add_file_now("name", "/tmp/path");  # read file immediately

 syswrite INPUT, $input->data, $input->length;   # if you really have to

 # $test is a CGI::Test object
 $test->POST("http://server:70/cgi-bin/script", $input);

=head1 DESCRIPTION

The C<CGI::Test::Input> class is deferred.  It is an abstract representation
of HTTP POST request input, as expected by the C<POST> routine of C<CGI::Test>.

Unless you wish to issue a C<POST> request manually to provide carefully
crafted input, you do not need to learn the interface of this hierarchy,
nor even bother knowing about it.

Otherwise, you need to decide which MIME encoding you want, and create an
object of the appropriate type.  Note that file uploading requires the use
of the C<multipart/form-data> encoding:

           MIME Encoding                    Type to Create
 ---------------------------------   ---------------------------
 application/x-www-form-urlencoded   CGI::Test::Input::URL
 multipart/form-data                 CGI::Test::Input::Multipart

Once the object is created, you will be able to add name/value tuples
corresponding to the CGI parameters to submit.

For instance:

    my $input = CGI::Test::Input::Multipart->make();
    $input->add_field("login", "ram");
    $input->add_field("password", "foobar");
    $input->add_file("organization", "/etc/news/organization");

Then, to inspect what is normally sent to the HTTP server:

    print "Content-Type: ", $input->mime_type, "\015\012";
    print "Content-Length: ", $input->length, "\015\012";
    print "\015\012";
    print $input->data;

But usually you'll hand out the $input object to the C<POST> routine
of C<CGI::Test>.

=head1 INTERFACE

=head2 Creation Routine

It is called C<make> as usual.  All subclasses have
the same creation routine signature, which takes no parameter.

=head2 Adding Parameters

CGI parameter are name/value tuples.  In case of file uploads, they can have
a content as well, the value being the file path on the client machine.

=over 4

=item C<add_field> I<name>, I<value>

Adds the CGI parameter I<name>, whose value is I<value>.

=item add_file I<name>, I<path>

Adds the file upload parameter I<name>, located at I<path>.

The file is not read immediately, so it must remain available until
the I<data> routine is called, at least.  It is not an error if the file
cannot be read at that time.

When not using the C<multipart/form-data> encoding, only the name/path
tuple will be transmitted to the script.

=item add_file_now I<name>, I<path>

Same as C<add_file>, but the file is immediately read and can therefore
be disposed of afterwards.  However, the file B<must> exist.

=item add_widget I<widget>

Add any widget, i.e. a C<CGI::Test::Form::Widget> object.  This routine
is called internally by C<CGI::Test> to construct the input data when
submiting a form via POST.

=back

=head2 Generation

=over 4

=item C<data>

Returns the data, under the proper encoding.

=item C<mime_type>

Returns the proper MIME encoding type, suitable for inclusion within
a Content-Type header.

=item C<length>

Returns the data length.

=head1 BUGS

Please let me know about them.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test(3), CGI::Test::Input::URL(3), CGI::Test::Input::Multipart(3).

=cut

