#
# $Id: Hidden.pm,v 0.1 2001/03/31 10:54:02 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Hidden.pm,v $
# Revision 0.1  2001/03/31 10:54:02  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form::Widget::Hidden;

#
# This class models a FORM hidden field.
#

require CGI::Test::Form::Widget;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Form::Widget);

use Carp::Datum;
use Log::Agent;

#
# %attr
#
# Defines which HTML attributes we should look at within the node, and how
# to translate that into class attributes.
#

my %attr = (
	'name'		=> 'name',
	'value'		=> 'value',
	'disabled'	=> 'is_disabled',
);

#
# ->_init
#
# Per-widget initialization routine.
# Parse HTML node to determine our specific parameters.
#
sub _init {
	DFEATURE my $f_;
	my $self = shift;
	my ($node) = shift;
	$self->_parse_attr($node, \%attr);
	return DVOID;
}

#
# ->_is_successful		-- defined
#
# Is the enabled widget "successful", according to W3C's specs?
# Any hidden field with a VALUE attribute is.
#
sub _is_successful {
	DFEATURE my $f_;
	my $self = shift;
	return DVAL defined $self->value;
}

#
# Attribute access
#

sub gui_type		{ "hidden field" }

#
# Global widget predicates
#

sub is_read_only	{ 1 }

#
# High-level classification predicates
#

sub is_hidden	{ 1 }

1;

=head1 NAME

CGI::Test::Form::Widget::Hidden - A hidden field

=head1 SYNOPSIS

 # Inherits from CGI::Test::Form::Widget

=head1 DESCRIPTION

This class represents a hidden field, which is meant to be resent as-is
upon submit.  Such a widget is therefore read-only.

The interface is the same as the one described
in L<CGI::Test::Form::Widget>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Form::Widget(3).

=cut
