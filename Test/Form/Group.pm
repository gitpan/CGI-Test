package CGI::Test::Form::Group;
use strict;
################################################################
# $Id: Group.pm,v 1.2 2003/09/29 11:00:38 mshiltonj Exp $
# $Name: cgi-test_0-104_t1 $
################################################################
#  Copyright (c) 2001, Raphael Manfredi
#
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.

#
# This class records names of grouped objects (radio buttons, checkboxes),
# and which buttons belong to some named group.
#

use Carp::Datum;
use Log::Agent;

#
# ->new
#
# Creation routine
#
# From a listref of box widgets, build a hash table indexed by group name
# and listing all the buttons belonging to the named group.  Each box is
# also made aware of this object.
#
sub new
{
    DFEATURE my $f_;
    my $this = bless {}, shift;    # The object is the hash table we use
    my ($rlist) = @_;

    DREQUIRE ref $rlist eq 'ARRAY';
    DREQUIRE @$rlist > 0;

    #
    # Create map: "group name" => [list of buttons in group]
    #

    foreach my $b (@$rlist)
    {
        DASSERT ref $b && $b->isa("CGI::Test::Form::Widget::Box");
        my $gname = $b->name;
        $this->{$gname} = [] unless exists $this->{$gname};
        push @{$this->{$gname}}, $b;
        $b->set_group($this);
    }

    $this->_validate_radios() if $rlist->[ 0 ]->is_radio();

    return DVAL $this;
}

#
# Attribute access
#

sub names
{
    my $this = shift;
    return keys %{$this};
}

#
# ->widgets_in
#
# Returns list of widgets held within named group, empty if none.
#
sub widgets_in
{
    DFEATURE my $f_;
    my $this = shift;
    my ($gname) = @_;

    my $list = $this->{$gname} || [];
    return DARY @$list;
}

#
# ->widget_count
#
# Returns amount of widgets held within named group, 0 if none.
#
sub widget_count
{
    DFEATURE my $f_;
    my $this = shift;
    my ($gname) = @_;

    my $list = $this->{$gname};
    return DVAL ref $list ? scalar(@$list) : 0;
}

#
# ->is_groupname
#
# Check whether name is that of a known widget group.
#
sub is_groupname
{
    DFEATURE my $f_;
    my $this = shift;
    my ($gname) = @_;

    return DVAL exists $this->{$gname};
}

#
# ->_validate_radios
#
# When groupping radio buttons, make sure there is at least one such
# button selected, otherwise mark the first as selected.  Also ensure
# exactly one radio is selected, or unselect all extra.
#
sub _validate_radios
{
    DFEATURE my $f_;
    my $this = shift;

    foreach my $gname ($this->names)
    {
        my @checked = grep {$_->is_checked} $this->widgets_in($gname);
        my $checked = @checked;

        if ($checked > 1)
        {
            my $first = shift @checked;

            #
            # NB: we're not calling uncheck() nor set_is_checked() to fix
            # incorrectly configured radio buttons, since it is normally an
            # invalid operation.  We're resettting the attribute directly.
            #

            logwarn
              "found %d checked %ss for '%s', keeping first (tag \"%s\")",
              $checked, $first->gui_type, $gname, ($first->value || "");

            foreach my $b (@checked)
            {
                $b->{is_checked} = 0;    # Direct access
            }
        }
        elsif ($checked == 0)
        {
            my $first = $this->{$gname}->[ 0 ];
            logwarn "no checked %ss for '%s', checking first (tag \"%s\")",
              $first->gui_type, $gname, ($first->value || "");
            $first->{is_checked} = 1;    # Direct access
        }

        DASSERT 1 == grep($_->is_checked, $this->widgets_in($gname)),
          "exactly one radio button checked for group '$gname'";
    }

    return DVOID;
}

1;

=head1 NAME

CGI::Test::Form::Group - Records groups of box-type widgets

=head1 SYNOPSIS

 # $form is a CGI::Test::Form object

 use CGI::Test;

 my $rgroup = $form->radio_groups;
 ok 1, defined $rgroup;

 my @title = $rgroup->widgets_in("title");
 my ($mister) = grep { $_->value eq "Mr" } @title;
 ok 2, $mister->is_checked;

=head1 DESCRIPTION

This class is a container for box-type widgets, i.e. radio buttons and
checkboxes, which may be groupped by name.

It can be queried to easily retrieve widgets belonging to a group, or to
get all the group names.

It is also used internally by C<CGI::Test> to keep track of associated
radio buttons, so that checking one automatically unchecks the others in the
same group.

=head1 INTERFACE

The following features are available:

=over 4

=item C<is_groupname> I<name>

Checks whether I<name> is the name of a group.

=item C<names>

Returns a list of group names, in random order.

=item C<widget_count> I<groupname>

Returns amount of widgets held in I<groupname>, 0 if none.

=item C<widgets_in> I<groupname>

Returns a list of all the widgets in the given I<groupname>.  If the
name is not a valid group name, the list will be empty.

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

CGI::Test::Form(3), CGI::Test::Form::Widget::Box(3).

=cut

