#
# $Id: Box.pm,v 0.1 2001/03/31 10:54:01 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Box.pm,v $
# Revision 0.1  2001/03/31 10:54:01  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Box;

#
# This class models a FORM box, either a radio button or a checkbox.
#

require CGI::Test::Form::Widget;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget);

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
	'checked'	=> 'is_checked',
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
	return DVOID;
}

#
# ->_is_successful		-- defined
#
# Is the enabled widget "successful", according to W3C's specs?
# Any ticked checkbox and radio button is.
#
sub _is_successful {
	DFEATURE my $f_;
	my $self = shift;
	return DVAL $self->is_checked;
}

#
# ->group_list
#
# Returns list of widgets belonging to the same group as we do.
#
sub group_list {
	DFEATURE my $f_;
	my $self = shift;

	DREQUIRE defined $self->group, "widget has been classified in a group";

	return DARY $self->group->widgets_in($self->name);
}

#
# Local attribute access
#

sub group			{ $_[0]->{group} }
sub is_checked		{ $_[0]->{is_checked} }
sub old_is_checked	{ $_[0]->{old_is_checked} }

#
# Checking shortcuts
#

sub check			{ $_[0]->set_is_checked(1) }
sub uncheck			{ $_[0]->set_is_checked(0) }

sub check_tagged	{ $_[0]->_mark_by_tag($_[1], 1) }
sub uncheck_tagged	{ $_[0]->_mark_by_tag($_[1], 0) }

#
# Attribute setting
#

sub set_group		{ $_[0]->{group} = $_[1] }

#
# ->set_is_checked
#
# Select or unselect box.
#
sub set_is_checked {
	DFEATURE my $f_;
	my $self = shift;
	my ($checked) = @_;

	return DVOID if !$checked == !$self->is_checked;	# No change

	#
	# To ease redefinition, let this call _frozen_set_is_checked, which is
	# not redefinable and performs the common operation.
	#

	$self->_frozen_set_is_checked($checked);
	return DVOID;
}

#
# ->reset_state			-- redefined
#
# Called when a "Reset" button is pressed to restore the value the widget
# had upon form entry.
#
sub reset_state {
	DFEATURE my $f_;
	my $self = shift;
	
	$self->{is_checked} = delete $self->{old_is_checked}
		if exists $self->{old_is_checked};

	return DVOID;
}

#
# Global widget predicates
#

sub is_read_only	{ 1 }

#
# High-level classification predicates
#

sub is_box		{ 1 }

#
# Predicates for the Box hierarchy
#

sub is_radio		{ logconfess "deferred" }
sub is_standalone	{ 1 == $_[0]->group->widget_count($_[0]->name) }

#
# ->delete
#
# Break circular refs.
#
sub delete {
	DFEATURE my $f_;
	my $self = shift;

	delete $self->{group};
	$self->SUPER::delete;

	return DVOID;
}

#
# ->_frozen_set_is_checked
#
# Frozen implementation of set_is_checked().
#
sub _frozen_set_is_checked {
	DFEATURE my $f_;
	my $self = shift;
	my ($checked) = @_;

	#
	# The first time we do this, save current status in `old_is_checked'.
	#

	$self->{old_is_checked} = $self->{is_checked}
		unless exists $self->{old_is_checked};
	$self->{is_checked} = $checked;

	return DVOID;
}

#
# ->_mark_by_tag
#
# Lookup the box in the group whose name is the given tag, and mark it
# as specified.
#
sub _mark_by_tag {
	DFEATURE my $f_;
	my $self = shift;
	my ($tag, $checked) = @_;

	my @boxes = grep { $_->value eq $tag } $self->group_list;

	if (@boxes == 0) {
		logcarp "no %s within the group '%s' bears the tag \"$tag\"",
			$self->gui_type, $self->name;
	} else {
		logcarp "found %d %ss within the group '%s' bearing the tag \"$tag\"",
			scalar(@boxes), $self->gui_type, $self->name if @boxes > 1;

		$boxes[0]->set_is_checked($checked);
	}

	return DVOID;
}

1;

=head1 NAME

CGI::Test::Form::Widget::Box - Abstract representation of a tickable box

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget

=head1 DESCRIPTION

This class is the abstract representation of a tickable box, i.e. a radio
button or a checkbox.

To simulate user checking or un-checking on a box,
use the C<check()> and C<uncheck()> routines, as described below.

=head1 INTERFACE

The interface is the same as the one described in L<CGI::Test::Form::Widget>,
with the following additions:

=head2 Attributes

=over 4

=item C<group>

The C<CGI::Test::Form::Group> object which holds all the groups of the same
widget type.

=item C<group_list>

The list of widgets belonging to the same group as we do.

=item C<is_checked>

True when the box is checked, i.e. marked with a tick.

=back

=head2 Attribute Setting

=over 4

=item C<check>

Check the box, by ticking it.

=item C<check_tagged> I<tag>

This may be called on any box, and it will locate the box whose value
attribute is I<tag> within the C<group_list>, and then check it.

If the specified I<tag> is not found, the caller will get a warning
via C<logcarp>.

=item C<uncheck>

Uncheck the box, by removing its ticking mark.
It is not possible to do this on a radio button: you must I<check> another
radio button of the same group instead.

=item C<uncheck_tagged> I<tag>

This may be called on any box, and it will locate the box whose value
attribute is I<tag> within the C<group_list>, and then remove its ticking mark.
It is not possible to do this on a radio button, as explained in C<uncheck>
above.

If the specified I<tag> is not found, the caller will get a warning
via C<logcarp>.

=back

=head2 Widget Classification Predicates

There is an additional predicate to distinguish between a checkbox and
a radio button:

=over 4

=item C<is_radio>

Returns I<true> for a radio button.

=item C<is_standalone>

Returns I<true> if the box is the sole member of its group.

Normally only useful for checkboxes: a standalone radio button,
although perfectly legal, would always remain in the checked state, and
therefore not be especially interesting...

=back

=head2 Miscellaneous Features

Although documented, those features are more targetted for
internal use...

=over 4

=item C<set_is_checked> I<flag>

Change the checked status.  Radio buttons can only be checked, i.e. the
I<flag> must be true: all other radio buttons in the same group are
immediately unchecked.

You should use the C<check> and C<uncheck> convenience routines instead
of calling this feature.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget(3),
CGI::Test::Form::Widget::Box::Radio(3),
CGI::Test::Form::Widget::Box::Check(3).

=cut

