#
# $Id: Radio.pm,v 0.1 2001/03/31 10:54:01 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Radio.pm,v $
# Revision 0.1  2001/03/31 10:54:01  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Box::Radio;

#
# This class models a FORM radio button.
#

require CGI::Test::Form::Widget::Box;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Box);

use Carp::Datum;
use Log::Agent;

#
# ->set_is_checked		-- redefined
#
# Change checked state.
#
# A radio button can only be "clicked on", i.e. it is not otherwise
# un-checkable.  Therefore, $checked must always be true.  Furthermore,
# all related radio buttons must be cleared.
#
sub set_is_checked {
	DFEATURE my $f_;
	my $self = shift;
	my ($checked) = @_;

	DREQUIRE $checked, "can only click on radio buttons";

	return DVOID if !$checked == !$self->is_checked;	# No change

	#
	# We're checking a radio button that was cleared previously.
	# All the other radio buttons in the group are going to be cleared.
	#

	$self->_frozen_set_is_checked($checked);
	foreach my $radio ($self->group_list) {
		next if $radio == $self;
		$radio->_frozen_set_is_checked(0);
	}

	DENSURE $self->is_checked, "radio button is checked";

	return DVOID;
}

sub uncheck			{ logcarp "ignoring uncheck on radio button" }
sub uncheck_tagged	{ logcarp "ignoring uncheck_tagged on radio button" }

#
# Attribute access
#

sub gui_type	{ "radio button" }
#
# Defined predicates
#

sub is_radio	{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Box::Radio - A radio button widget

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Box
 # $form is a CGI::Test::Form

 my @title = $form->radios_named("title");
 my ($mister) = grep { $_->value eq "Mr" } @title;
 $mister->check if defined $mister;

 my $title = $form->radio_by_name("title");
 $title->check_tagged("Mr");

=head1 DESCRIPTION

This class represents a radio button widget, which may be checked at
will by users.  All other radio buttons of the same group are automatically
unchecked.

If no radio button is checked initially, C<CGI::Test> arbitrarily chooses
the first one listed and warns you via C<logwarn>.

The interface is the same as the one described
in L<CGI::Test::Form::Widget::Box>.

Any attempt to C<uncheck> a radio button will be ignored, and a warning
emitted via C<logcarp>, to help you identify the caller.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Box(3), CGI::Test::Form::Widget::Box::Check(3),
Log::Agent(3).

=cut

