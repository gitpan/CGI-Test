#
# $Id: Plain.pm,v 0.1 2001/03/31 10:54:01 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Plain.pm,v $
# Revision 0.1  2001/03/31 10:54:01  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Button::Plain;

#
# This class models a FORM plain <BUTTON>.
#

require CGI::Test::Form::Widget::Button;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Button);

use Carp::Datum;
use Log::Agent;

#
# Attribute access
#

sub gui_type	{ "plain button" }

#
# Button predicates
#

sub is_plain	{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Button::Plain - A button with client-side processing

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Button

=head1 DESCRIPTION

This class models a plain button, which probably has some client-side
processing attached to it.  Unfortunately, C<CGI::Test> does not support
this, so there's not much you can do with this button, apart from making
sure it is present.

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Button>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Button(3).

=cut

