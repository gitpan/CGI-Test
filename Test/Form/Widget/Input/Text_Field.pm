#
# $Id: Text_Field.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Text_Field.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Input::Text_Field;

#
# This class models a FORM text field.
#

require CGI::Test::Form::Widget::Input;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Input);

use Carp::Datum;
use Log::Agent;

#
# %attr
#
# Defines which HTML attributes we should look at within the node, and how
# to translate that into class attributes.
#

my %attr = (
	'name'		=> 'name',
	'value'		=> 'value',
	'size'		=> 'size',
	'maxlength'	=> 'max_length',
	'disabled'	=> 'is_disabled',
	'readonly'	=> 'is_read_only',
);

#
# ->_init
#
# Per-widget initialization routine.
# Parse HTML node to determine our specific parameters.
#
sub _init {
	DFEATURE my $f_;
	my $self = shift;
	my ($node) = shift;
	$self->_parse_attr($node, \%attr);
	return DVOID;
}

#
# Attribute access
#

sub size		{ $_[0]->{size} }
sub max_length	{ $_[0]->{max_length} }

sub gui_type	{ "text field" }

#
# Redefined predicates
#

sub is_field	{ 1 }

#
# Redefined routines
#

#
# ->set_value		-- redefined
#
# Ensure text is not larger than the maximum field length, by truncating
# from the right.
#
sub set_value {
	DFEATURE my $f_;
	my $self = shift;
	my ($value) = @_;

	my $maxlen = $self->max_length;
	$maxlen = 1 if defined $maxlen && $maxlen < 1;

	if (defined $maxlen && length($value) > $maxlen) {
		logcarp "truncating text to %d byte%s for %s '%s'",
			$maxlen, $maxlen == 1 ? "" : "s", $self->gui_type, $self->name;
		substr($value, $maxlen) = '';
	}

	DASSERT !defined($maxlen) || length($value) <= $maxlen;

	$self->SUPER::set_value($value);
}

1;

=head1 NAME

CGI::Test::Form::Widget::Input::Text_Field - A text field

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Input
 # $form is a CGI::Test::Form

 my $desc = $form->input_by_name("description");
 $desc->replace("small and beautiful");

=head1 DESCRIPTION

This class models a single-line text field, where users can type text.

=head1 INTERFACE

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Input>, with the following additional attributes:

=over 4

=item C<max_length>

The maximum allowed text length within the field.  If not defined, it means
the length is not limited.

=item C<size>

The size of the displayed text field, in characters.  The text held within
the field can be much larger than that, however.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Input(3).

=cut

