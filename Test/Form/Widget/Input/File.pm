#
# $Id: File.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: File.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Input::File;

#
# This class models a FORM file input for uploading.
#
# It inherits from Text_Field, since the only distinction between a text field
# and a file upload field is the presence of the "browse" button displayed by
# the browser to select a file.
#

require CGI::Test::Form::Widget::Input::Text_Field;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget::Input::Text_Field);

use Carp::Datum;
use Log::Agent;

#
# Attribute access
#

sub gui_type	{ "file upload" }

#
# Redefined predicates
#

sub is_field	{ 0 }			# not a pure text field
sub is_file		{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Input::File - A file upload control

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Input
 # $form is a CGI::Test::Form

 my $upload = $form->input_by_name("upload");
 $upload->replace("/tmp/file");

=head1 DESCRIPTION

This class models a file upload control, which is a text field to enter
a file name, with a little "browse" control button nearby that allows
the user to select a file via a GUI...

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Input::Text_Field>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget::Input(3).

=cut

