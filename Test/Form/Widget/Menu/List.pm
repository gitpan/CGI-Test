#
# $Id: List.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: List.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Menu::List;

#
# This class models a FORM scrollable list.
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
	'size'		=> 'size',
	'multiple'	=> 'multiple',
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
# ->submit_tuples		-- redefined
#
# Returns list of (name => value) tuples that should be part of the
# submitted form data.
#
sub submit_tuples {
	DFEATURE my $f_;
	my $self = shift;

	DREQUIRE $self->is_submitable;

	return DARY map { $self->name => $_ } keys %{$self->selected};
}

#
# Attribute access
#

sub size		{ $_[0]->{size} }
sub gui_type	{ "scrolling list" }

#
# Defined predicates
#

sub is_popup	{ 0 }

1;

=head1 NAME

CGI::Test::Form::Widget::Menu::List - A scrolling list menu

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Menu
 # $form is a CGI::Test::Form

 my $action = $form->menu_by_name("action");
 $action->unselect("allow-gracetime");
 $action->select("reboot");

=head1 DESCRIPTION

This class models a scrolling list menu, from which items may be selected
and unselected.

=head1 INTERFACE

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Menu>, with the following additional attribute:

=over 4

=item C<size>

The amount of choices displayed.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Menu(3).

=cut

