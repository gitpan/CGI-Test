package CGI::Test::Form::Widget::Menu::List;
use strict;
##################################################################
# $Id: List.pm,v 1.2 2003/09/29 11:00:47 mshiltonj Exp $
# $Name: cgi-test_0-104_t1 $
##################################################################
#
#  Copyright (c) 2001, Raphael Manfredi
#
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.

#
# This class models a FORM scrollable list.
#

use CGI::Test::Form::Widget::Menu;
use base qw(CGI::Test::Form::Widget::Menu);

use Carp::Datum;
use Log::Agent;

#
# %attr
#
# Defines which HTML attributes we should look at within the node, and how
# to translate that into class attributes.
#

my %attr = ('name'     => 'name',
            'size'     => 'size',
            'multiple' => 'multiple',
            'disabled' => 'is_disabled',
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
    $this->_parse_options($node);
    return DVOID;
}

#
# ->submit_tuples		-- redefined
#
# Returns list of (name => value) tuples that should be part of the
# submitted form data.
#
sub submit_tuples
{
    DFEATURE my $f_;
    my $this = shift;

    DREQUIRE $this->is_submitable();

    return DARY map {$this->name => $_} keys %{$this->selected()};
}

#
# Attribute access
#

sub size
{
    my $this = shift;
    return $this->{size};
}

sub gui_type
{
    "scrolling list"
}

#
# Defined predicates
#

sub is_popup
{
    return 0;
}

1;

=head1 NAME

CGI::Test::Form::Widget::Menu::List - A scrolling list menu

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget::Menu
 # $form is a CGI::Test::Form

 my $action = $form->menu_by_name("action");
 $action->unselect("allow-gracetime");
 $action->select("reboot");

=head1 DESCRIPTION

This class models a scrolling list menu, from which items may be selected
and unselected.

=head1 INTERFACE

The interface is the same as the one described in
L<CGI::Test::Form::Widget::Menu>, with the following additional attribute:

=over 4

=item C<size>

The amount of choices displayed.

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

CGI::Test::Form::Widget::Menu(3).

=cut

