#
# $Id: Text.pm,v 0.1 2001/03/31 10:54:03 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Text.pm,v $
# Revision 0.1  2001/03/31 10:54:03  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Page::Text;

use Carp::Datum;
use Getargs::Long;

require CGI::Test::Page::Real;
use vars qw(@ISA);
@ISA = qw(CGI::Test::Page::Real);

#
# ->make
#
# Creation routine
#
sub make {
	DFEATURE my $f_;
	my $self = bless {}, shift;
	$self->_init(@_);
	return DVAL $self;
}

#
# Attribute access
#

1;

=head1 NAME

CGI::Test::Page::Text - A text page reply

=head1 SYNOPSIS

 # Inherits from CGI::Test::Page::Real

=head1 DESCRIPTION

This class represents an HTTP reply containing C<text/plain> data.
Its interface is the same as the one described in L<CGI::Test::Page::Real>.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Page::Real(3).

=cut

