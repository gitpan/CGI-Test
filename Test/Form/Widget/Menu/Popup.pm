#
# $Id: Popup.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Popup.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Menu::Popup;

#
# This class models a FORM popup menu.
#

require CGI::Test::Form::Widget::Menu;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Menu);

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
	'disabled'	=> 'is_disabled',
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
	$self->_parse_options($node);
	return DVOID;
}

#
# ->set_selected		-- redefined
#
# Change "selected" status for a menu value.
# We can only "select" values from a popup, never unselect one.
#
sub set_selected {
	DFEATURE my $f_;
	my $self = shift;
	my ($value, $state) = @_;

	unless ($state) {
		logcarp "cannot unselect value \"%s\" from popup $self", $value;
		return DVOID;
	}

	return $self->SUPER::set_selected($value, $state);
}

#
# Attribute access
#

sub gui_type	{ "popup menu" }

#
# Defined predicates
#

sub is_popup	{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Menu::Popup - A popup menu

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Menu
 # $form is a CGI::Test::Form

 my $action = $form->menu_by_name("action");
 $action->select("reboot");

=head1 DESCRIPTION

This class models a popup menu, from which one item at most may be selected,
and for which there is at least one item selected, i.e. where exactly one
item is chosen.

If no item was explicitely selected, C<CGI::Test> arbitrarily chooses the
first item in the popup (if not empty) and warns you via C<logwarn>.

=head1 INTERFACE

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Menu>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Menu(3).

=cut

