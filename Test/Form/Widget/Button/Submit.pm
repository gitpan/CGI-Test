#
# $Id: Submit.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Submit.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Button::Submit;

#
# This class models a FORM submit button.
#

require CGI::Test::Form::Widget::Button;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Button);

use Carp::Datum;
use Log::Agent;

#
# Attribute access
#

sub gui_type	{ "submit button" }

#
# ->press
#
# Press button.
# Has immediate effect: a GET/POST request is issued.
#
# Returns resulting CGI::Test::Page.
#
sub press {
	DFEATURE my $f_;
	my $self = shift;
	$self->set_is_pressed(1);
	return DVAL $self->form->submit;
}

#
# Button predicates
#

sub is_submit	{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Button::Submit - A submit button

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Button
 # $form is a CGI::Test::Form

 my $send = $form->submit_by_name("send");
 my $answer = $send->press;

=head1 DESCRIPTION

This class models a submit button.
Pressing it immediately triggers an HTTP request, as defined by the form.

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Button>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Button(3).

=cut

