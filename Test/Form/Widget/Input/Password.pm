#
# $Id: Password.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Password.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Input::Password;

#
# This class models a FORM password input field.
#
# It inherits from Text_Field, since the only distinction between a text field
# and a password field is whether characters are shown as typed or not.
#

require CGI::Test::Form::Widget::Input::Text_Field;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Input::Text_Field);

use Carp::Datum;
use Log::Agent;

#
# Attribute access
#

sub gui_type	{ "password field" }

#
# Redefined predicates
#

sub is_field	{ 0 }			# not a pure text field
sub is_password	{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Input::Password - A password field

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Input
 # $form is a CGI::Test::Form

 my $passwd = $form->input_by_name("password");
 $passwd->replace("foobar");

=head1 DESCRIPTION

This class models a password field, which is a text field whose input
is masked by the browser, but which otherwise behaves like a regular
text field.

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Input::Text_Field>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Input(3).

=cut

