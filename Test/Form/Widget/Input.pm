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

package CGI::Test::Form::Widget::Input;

#
# This class models a FORM input field.
# It factorizes the interface of our heirs: Text_Area and Text_Field
#

require CGI::Test::Form::Widget;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget);

use Carp::Datum;
use Log::Agent;

#
# ->_is_successful		-- defined
#
# Is the enabled widget "successful", according to W3C's specs?
# Any input is.
#
sub _is_successful {
	DFEATURE my $f_;
	my $self = shift;
	return DVAL 1;
}

#
# Editing shortcuts
#
# The set_value() routine from the Widget class is protected against
# disabled and read-only fields, so don't duplicate checks within these
# shortcut routines.
#
# All are obvious, excepted filter perhaps, which runs a filtering subroutine
# on the field's value, preset in $_:
#
#   $i->filter(sub { s/this/that/ });
#
# In the traditional Perl way...
#

sub prepend		{ $_[0]->set_value($_[1] . $_[0]->value) }
sub append		{ $_[0]->set_value($_[0]->value . $_[1]) }
sub replace		{ $_[0]->set_value($_[1]) }
sub clear		{ $_[0]->set_value('') }
sub filter		{ local $_ = $_[0]->value; &{$_[1]}; $_[0]->set_value($_) }

#
# Attribute access
#

sub is_read_only	{ $_[0]->{is_read_only} }

#
# High-level classification predicates
#

sub is_input	{ 1 }

#
# Predicates for the Input hierarchy
#

sub is_field	{ 0 }
sub is_area		{ 0 }
sub is_password	{ 0 }
sub is_file		{ 0 }

1;

=head1 NAME

CGI::Test::Form::Widget::Input - Abstract representation of an input field

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget

=head1 DESCRIPTION

This class is the abstract representation of a text input field, i.e. a
text field, a password field, a file upload field or a text area.

To simulate user input in those fields, there are a set of routines to
C<prepend()>, C<append()>, C<replace()>, C<clear()> or even run existing text
through C<filter()>.

=head1 INTERFACE

The interface is the same as the one described in L<CGI::Test::Form::Widget>,
with the following additions:

=head2 Attribute Setting

There are a number of convenience routines that are wrappers on C<set_value()>:

=over 4

=item C<append> I<string>

Appends the I<string> text to the existing text.

=item C<clear>

Clears existing text.

=item C<filter> I<filter_routine>

Runs existing text through the given I<filter_routine>.  The C<$_> variable
is set to the whole text value, and is made available to the filter.
Hence you may write:

    $input->filter(sub { s/this/that/g });

to replace all instances of C<this> by C<that> within the input text.

=item C<prepend> I<string>

Prepends the I<string> text to the existing text.

=item C<replace> I<string>

Replaces the existing text with I<string>.

=back

=head2 Widget Classification Predicates

There are additional predicates to distinguish between the various
input fields:

=over 4

=item C<is_area>

Returns I<true> for a text area.

=item C<is_field>

Returns I<true> for a pure text field.

=item C<is_file>

Returns I<true> for a file upload field (text field with browser support for
file selection).

=item C<is_password>

Returns I<true> for a password field (text field with input masked by GUI).

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget(3),
CGI::Test::Form::Widget::Input::File(3),
CGI::Test::Form::Widget::Input::Password(3),
CGI::Test::Form::Widget::Input::Text_Area(3),
CGI::Test::Form::Widget::Input::Text_Field(3).

=cut

