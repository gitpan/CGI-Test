#
# $Id: Text_Area.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Text_Area.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Input::Text_Area;

#
# This class models a FORM textarea input field.
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
	'rows'		=> 'rows',
	'cols'		=> 'columns',
	'wrap'		=> 'wrap_mode',
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

sub rows		{ $_[0]->{rows} }
sub columns		{ $_[0]->{columns} }
sub wrap_mode	{ $_[0]->{wrap_mode} }

sub gui_type	{ "text area" }

#
# Redefined predicates
#

sub is_area		{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Input::Text_Area - A text area

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Input
 # $form is a CGI::Test::Form

 my $comments = $form->input_by_name("comments");
 $comments->append(<<EOM);
 -- 
 There's more than one way to do it.
     --Larry Wall
 EOM

=head1 DESCRIPTION

This class models a text area, where users can type text.

=head1 INTERFACE

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Input>, with the following additional attributes:

=over 4

=item C<columns>

Amount of displayed columns.

=item C<rows>

Amount of displayed text rows.

=item C<wrap_mode>

The selected work wrapping mode.

=back

=head1 BUGS

Does not handle C<wrap_mode> and C<columns> yet.  There is actually some work
done by the browser when the wrapping mode is set to C<"hard">, which alters
the value transmitted back to the script upon submit.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Input(3).

=cut

