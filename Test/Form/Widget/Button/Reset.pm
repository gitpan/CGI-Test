#
# $Id: Reset.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Reset.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Button::Reset;

#
# This class models a FORM reset button.
#

require CGI::Test::Form::Widget::Button;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Button);

use Carp::Datum;
use Log::Agent;

#
# Attribute access
#

sub gui_type	{ "reset button" }

#
# ->press
#
# Press button.
# Has immediate effect: all widgets are reset to their initial state.
#
# Returns undef.
#
sub press {
	DFEATURE my $f_;
	my $self = shift;
	$self->form->reset;
	return DVAL undef;
}

#
# Global widget predicates
#

sub is_read_only	{ 1 }		# Handled internally by client

#
# Button predicates
#

sub is_reset	{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Button::Reset - A reset button

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Button
 # $form is a CGI::Test::Form

 my @reset = $form->buttons_matching(sub { $_[0]->is_reset });
 $reset[0]->press if @reset;

=head1 DESCRIPTION

This class models a reset button.  Pressing this buttom immediately
resets the form to its original state.  The processing is done on the
client-side, and no request is made to the HTTP server.

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Button>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Button(3).

=cut

