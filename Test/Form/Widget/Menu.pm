#
# $Id: Menu.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Menu.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Menu;

#
# This class models a FORM menu (either a popup or a scrollable list).
#

require CGI::Test::Form::Widget;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget);

use Carp::Datum;
use Log::Agent;
use Storable qw(dclone);

#
# ->_parse_options
#
# Parse <OPTION> items held within the <SELECT> node.
# We ignore <OPTGROUP> items, since those are only there for grouping options,
# and cannot be individually selected as such.
#
# The following attributes are used to record the options:
#
#  option_labels  listref of option labels, in the order they appear
#  option_values  listref of option values, in the order they appear
#  known_values   hashref, recording valid *values*
#  selected       hashref, recording selected *values*
#  selected_count amount of selected items
#
sub _parse_options {
	DFEATURE my $f_;
	my $self = shift;
	my ($node) = shift;

	DREQUIRE $node->tag eq "select";
	DREQUIRE $self->name ne "", "_parse_attr was already called";

	my $labels = $self->{option_labels} = [];
	my $values = $self->{option_values} = [];
	my $selected = $self->{selected} = {};
	my $known = $self->{known_values} = {};
	my $count = 0;
	my %seen;

	my @nodes = $node->look_down(sub { 1 });
	shift @nodes;			# first node is the <SELECT> itself

	foreach my $opt (@nodes) {
		next if $opt->tag eq "optgroup";
		unless ($opt->tag eq "option") {
			logwarn "ignoring non-option tag '%s' within SELECT", uc($opt->tag);
			next;
		}

		#
		# The option label is normally the content of the <OPTION> tag.
		# However, if there is a LABEL= within the tag, it should be used
		# in preference to the option content, says the W3C's norm.
		#

		my $label = $opt->attr("label") || $opt->as_text();
		my $is_selected = $opt->attr("selected");
		my $value = $opt->attr("value");

		unless (defined $value) {
			logwarn "ignoring OPTION tag with no value: %s", $opt->starttag;
			next;
		}

		#
		# It is not really an error to have duplicate values, but is it
		# a good interface style?  The user will be faced with multiple
		# labels to choose from, some of them being handled in the same way
		# since they bear the same value...  Tough choice... Let's warn!
		#

		logwarn "duplicate value '%s' in OPTION for SELECT NAME=\"%s\"",
			$value, $self->name if $seen{$value}++;

		push @$labels, $label;
		push @$values, $value;
		$known->{$value}++;				# help them spot dups
		if ($is_selected) {
			$selected->{$value}++;
			$count++;
		}
	}

	#
	# A popup menu needs to have at least one item selected.  We're the
	# user agent, and we get to choose which item we'll select implicitely.
	# Use the first listed value, if any.
	#

	if ($count == 0 && $self->is_popup && @$values) {
		my $first = $values->[0];
		$selected->{$first}++;
		$count++;
		logwarn "implicitely selecting OPTION '%s' for SELECT NAME=\"%s\"",
			$first, $self->name;
	}

	$self->{selected_count} = $count;

	DENSURE @{$self->option_labels} == @{$self->option_values};
	DENSURE scalar keys %{$self->selected} <= $self->selected_count;
	DENSURE $self->selected_count <= @{$self->option_values};
	DENSURE $self->selected_count >= 0 &&
		implies(!$self->multiple, $self->selected_count <= 1);
	DENSURE implies($self->is_popup && @{$self->option_values},
		$self->selected_count == 1);

	return DVOID;
}

#
# ->_is_successful		-- defined
#
# Is the enabled widget "successful", according to W3C's specs?
# Any menu with at least one selected item is.
#
sub _is_successful {
	DFEATURE my $f_;
	my $self = shift;
	return DVAL $self->selected_count > 0;
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

	my $name = $self->name;
	my $selected = $self->selected;

	my @tuples = map { $name => $_ } grep { $selected->{$_} }
		@{$self->option_values};

	return DARY @tuples;
}

#
# Attribute access
#

sub multiple		{ $_[0]->{multiple} }			# Set by Menu::List

sub option_labels	{ $_[0]->{option_labels} }
sub option_values	{ $_[0]->{option_values} }
sub known_values	{ $_[0]->{known_values} }
sub selected		{ $_[0]->{selected} }
sub selected_count	{ $_[0]->{selected_count} }
sub old_selected	{ $_[0]->{old_selected} }

#
# Selection shortcuts
#

sub select			{ $_[0]->set_selected($_[1], 1) }
sub unselect		{ $_[0]->set_selected($_[1], 0) }

#
# Global widget predicates
#

sub is_read_only	{ 1 }

#
# High-level classification predicates
#

sub is_menu		{ 1 }

#
# Predicates for menus
#

sub is_popup	{ logconfess "deferred" }

#
# ->is_selected
#
# Checks whether given value is selected.
#
sub is_selected {
	DFEATURE my $f_;
	my $self = shift;
	my ($value) = @_;

	unless ($self->known_values->{$value}) {
		logcarp "unknown value \"%s\" in $self", $value;
		return DVAL 0;
	}

	return DVAL exists $self->selected->{$value};
}

#
# ->set_selected
#
# Change "selected" status for a menu value.
#
sub set_selected {
	DFEATURE my $f_;
	my $self = shift;
	my ($value, $state) = @_;

	unless ($self->known_values->{$value}) {
		logcarp "unknown value \"%s\" in $self", $value;
		return DVOID;
	}

	my $is_selected = $self->is_selected($value);
	return DVOID if equiv($is_selected, $state);		# No change

	#
	# Save selected status for all the values the first time a change is made.
	#

	$self->{old_selected} = dclone $self->{selected}
		unless exists $self->{old_selected};

	#
	# If multiple selection is not authorized, clear the selection list.
	#

	my $selected = $self->selected;
	%$selected = () unless $self->multiple;

	$selected->{$value} = 1 if $state;
	delete $selected->{$value} unless $state;
	$self->{selected_count} = scalar keys %$selected;

	DENSURE equiv($state, $self->selected->{$value});
	DENSURE $self->selected_count >= 0 &&
		implies(!$self->multiple, $self->selected_count <= 1);

	return DVOID;
}

#
# ->reset_state
#
# Called when a "Reset" button is pressed to restore the value the widget
# had upon form entry.
#
sub reset_state {
	DFEATURE my $f_;
	my $self = shift;

	return DVOID unless exists $self->{old_selected};
	$self->{selected} = delete $self->{old_selected};
	$self->{selected_count} = scalar keys %{$self->selected};

	DENSURE $self->selected_count >= 0 &&
		implies(!$self->multiple, $self->selected_count <= 1);

	return DVOID;
}

1;

=head1 NAME

CGI::Test::Form::Widget::Menu - Abstract representation of a menu

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget

=head1 DESCRIPTION

This class is the abstract representation of a menu from which one can choose
one or several items, i.e. either a popup menu or a scrollable list
(with possibly multiple selections).

There is an interface to query the selected items, get at the presented
labels and associated values, and naturally C<select()> or C<unselect()>
items.

=head1 INTERFACE

The interface is the same as the one described in L<CGI::Test::Form::Widget>,
with the following additions:

=head2 Attributes

=over 4

=item C<known_values>

An hash reference, recording valid menu values, as tuples
(I<value> => I<count>), with I<count> set to the number of times the same
value is re-used amongst the proposed options.

=item C<multiple>

Whether menu allows multiple selections.

=item C<option_labels>

A list reference, providing the labels to choose from, in the order in which
they appear.  The retained labels are either the content of the <OPTION>
elements, or the value of their C<label> attribute, when specified.

=item C<option_values>

A list reference, providing the underlying values that the user chooses from
when he selects labels, in the order in which they appear in the menu.

=item C<selected>

An hash reference, whose keys are the selected values.

=item C<selected_count>

The amount of currently selected items.

=back

=head2 Attribute Setting

=over 4

=item C<select> I<value>

Mark the option I<value> as selected.  If C<multiple> is false, any
previously selected value is automatically unselected.

Note that this takes a I<value>, not a I<label>.

=item C<unselect> I<value>

Unselect an option I<value>.  It is not possible to do that on a popup
menu: you must C<select> another item to unselect any previously selected one.

=back

=head2  Menu Probing

=over 4

=item C<is_selected> I<value>

Test whether an option I<value> is currently selected or not.  This is
not testing a label, but a value, which is what the script will get back
eventually: labels are there for human consumption only.

=back

=head2 Widget Classification Predicates

There is an additional predicate to distinguish between a popup menu (single
selection mandatory) from a scrolling list (multiple selection allowed, and
may select nothing).

=over 4

=item C<is_popup>

Returns I<true> for a popup menu.

=back

=head2 Miscellaneous Features

Although documented, those features are more targetted for
internal use...

=over 4

=item C<set_selected> I<value>, I<flag>

Change the selection status of an option I<value>.

You should use the C<select> and C<unselect> convenience routines instead
of calling this feature.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget(3),
CGI::Test::Form::Widget::Menu::List(3),
CGI::Test::Form::Widget::Menu::Popup(3).

=cut
