package CGI::Test::Form::Widget::Input::Text_Field;
use strict;
##################################################################
# $Id: Text_Field.pm,v 1.2 2003/09/29 11:00:47 mshiltonj Exp $
# $Name: cgi-test_0-104_t1 $
##################################################################
#
#  Copyright (c) 2001, Raphael Manfredi
#
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
#
# This class models a FORM text field.
#

use CGI::Test::Form::Widget::Input;
use base qw(CGI::Test::Form::Widget::Input);

use Carp::Datum;
use Log::Agent;

#
# %attr
#
# Defines which HTML attributes we should look at within the node, and how
# to translate that into class attributes.
#

my %attr = ('name'      => 'name',
            'value'     => 'value',
            'size'      => 'size',
            'maxlength' => 'max_length',
            'disabled'  => 'is_disabled',
            'readonly'  => 'is_read_only',
            );

#
# ->_init
#
# Per-widget initialization routine.
# Parse HTML node to determine our specific parameters.
#
sub _init
{
    DFEATURE my $f_;
    my $this = shift;
    my ($node) = shift;
    $this->_parse_attr($node, \%attr);
    return DVOID;
}

#
# Attribute access
#

sub size
{
    $_[ 0 ]->{size};
}

sub max_length
{
    $_[ 0 ]->{max_length};
}

sub gui_type
{
    "text field"
}

#
# Redefined predicates
#

sub is_field
{
    1
}

#
# Redefined routines
#

#
# ->set_value		-- redefined
#
# Ensure text is not larger than the maximum field length, by truncating
# from the right.
#
sub set_value
{
    DFEATURE my $f_;
    my $this = shift;
    my ($value) = @_;

    my $maxlen = $this->max_length;
    $maxlen = 1 if defined $maxlen && $maxlen < 1;

    if (defined $maxlen && length($value) > $maxlen)
    {
        logcarp "truncating text to %d byte%s for %s '%s'", $maxlen,
          $maxlen == 1 ? "" : "s", $this->gui_type, $this->name;
        substr($value, $maxlen) = '';
    }

    DASSERT !defined($maxlen) || length($value) <= $maxlen;

    $this->SUPER::set_value($value);
}

1;

=head1 NAME

CGI::Test::Form::Widget::Input::Text_Field - A text field

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Input
 # $form is a CGI::Test::Form

 my $desc = $form->input_by_name("description");
 $desc->replace("small and beautiful");

=head1 DESCRIPTION

This class models a single-line text field, where users can type text.

=head1 INTERFACE

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Input>, with the following additional attributes:

=over 4

=item C<max_length>

The maximum allowed text length within the field.  If not defined, it means
the length is not limited.

=item C<size>

The size of the displayed text field, in characters.  The text held within
the field can be much larger than that, however.

=back

=head1 WEBSITE

You can find information about CGI::Test and other related modules at:

   http://cgi-test.sourceforge.net

=head1 PUBLIC CVS SERVER

CGI::Test now has a publicly accessible CVS server provided by
SourceForge (www.sourceforge.net).  You can access it by going to:

    http://sourceforge.net/cvs/?group_id=89570

=head1 AUTHORS

The original author is Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>. 

Send bug reports, hints, tips, suggestions to Steven Hilton at <mshiltonj@mshiltonj.com>

=head1 SEE ALSO

CGI::Test::Form::Widget::Input(3).

=cut

