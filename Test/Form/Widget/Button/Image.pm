#
# $Id: Image.pm,v 0.1 2001/03/31 10:54:01 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Image.pm,v $
# Revision 0.1  2001/03/31 10:54:01  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Button::Image;

#
# This class models a FORM image button.
# It's really a submit button in disguise as far as processing goes.
#

require CGI::Test::Form::Widget::Button::Submit;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Button::Submit);

use Carp::Datum;
use Log::Agent;

#
# Attribute access
#

sub gui_type	{ "image button" }

1;

=head1 NAME

CGI::Test::Form::Widget::Button::Image - A nice submit button

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Button
 # $form is a CGI::Test::Form

 my $send = $form->submit_by_name("send");
 my $answer = $send->press;

=head1 DESCRIPTION

This class models an image button.  Apart from the fact that it's probably
nicer on a browser, this widget otherwise behaves like your ordinary
submit button.

Pressing it immediately triggers an HTTP request, as defined by the form.

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Button>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Button(3).

=cut

