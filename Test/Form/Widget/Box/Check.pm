#
# $Id: Check.pm,v 0.1 2001/03/31 10:54:01 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Check.pm,v $
# Revision 0.1  2001/03/31 10:54:01  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Box::Check;

#
# This class models a FORM checkbox button.
#

require CGI::Test::Form::Widget::Box;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Box);

use Carp::Datum;
use Log::Agent;

#
# Attribute access
#

sub gui_type	{ "checkbox" }

#
# Defined predicates
#

sub is_radio	{ 0 }

1;

=head1 NAME

CGI::Test::Form::Widget::Box::Check - A checkbox widget

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Box
 # $form is a CGI::Test::Form

 use Log::Agent;    # logdie below

 my ($agree, $ads) = $form->checkbox_by_name(qw(i_agree ads));

 logdie "expected a standalone checkbox" unless $agree->is_standalone;
 $agree->check;
 $ads->uncheck_tagged("spam OK");

=head1 DESCRIPTION

This class represents a checkbox widget, which may be checked or unchecked
at will by users.

The interface is the same as the one described
in L<CGI::Test::Form::Widget::Box>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Box(3), CGI::Test::Form::Widget::Box::Radio(3).

=cut

