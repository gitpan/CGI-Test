#
# $Id: HTML.pm,v 0.1 2001/03/31 10:54:03 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: HTML.pm,v $
# Revision 0.1  2001/03/31 10:54:03  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Page::HTML;

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

sub tree		{ $_[0]->{tree}  || $_[0]->_build_tree }
sub forms		{ $_[0]->{forms} || $_[0]->_xtract_forms }
sub form_count	{
	$_[0]->_xtract_forms unless exists $_[0]->{form_count};
	return $_[0]->{form_count};
}

#
# ->_build_tree
#
# Parse HTML content from `raw_content' into an HTML tree.
# Only called the first time an access to `tree' is requested.
#
# Returns constructed tree object.
#
sub _build_tree {
	DFEATURE my $f_;
	my $self = shift;

	require HTML::TreeBuilder;

	my $tree = HTML::TreeBuilder->new();
	$tree->ignore_unknown(0);		# Keep everything, even unknown tags
	$tree->store_comments(1);		# Useful things may hide in "comments"
	$tree->store_declarations(1);	# Store everything that we may test
	$tree->store_pis(1);			# Idem
	$tree->warn(1);					# We want to know if there's a problem

	$tree->parse($self->raw_content);
	$tree->eof;

	return DVAL $self->{tree} = $tree;
}

#
# _xtract_forms
#
# Extract <FORMS> tags out of the tree, and for each form, build a
# CGI::Test::Form object that represents it.
# Only called the first time an access to `forms' is requested.
#
# Side effect: updates the `forms' and `form_count' attributes.
#
# Returns list ref of objects, in the order they were found.
#
sub _xtract_forms {
	DFEATURE my $f_;
	my $self = shift;
	my $tree = $self->tree;

	require CGI::Test::Form;

	#
	# The CGI::Test::Form objects we're about to create will refer back to
	# us, because they are conceptually part of this page.  Besides, their
	# HTML tree is a direct reference into our own tree.
	#

	my @forms = $tree->look_down(
		sub { $_[0]->tag eq "form" }
	);
	@forms = map { CGI::Test::Form->make($_, $self) } @forms;

	$self->{form_count} = scalar @forms;
	return DVAL $self->{forms} = \@forms;
}

#
# ->delete
#
# Break circular references
#
sub delete {
	DFEATURE my $f_;
	my $self = shift;

	#
	# The following attributes are "lazy", i.e. calculated on demand.
	# Therefore, take precautions before de-referencing them.
	#
 
	$self->{tree} = $self->{tree}->delete if ref $self->{tree};
	if (ref $self->{forms}) {
		foreach my $form (@{$self->{forms}}) {
			$form->delete;
		}
		delete $self->{forms};
	}

	$self->SUPER::delete;
	return DVOID;
}

#
# (DESTROY)
#
# Dispose of HTML tree properly
#
sub DESTROY {
	DFEATURE my $f_;
	my $self = shift;
	return DVOID unless ref $self->{tree};
	$self->{tree} = $self->{tree}->delete;
	return DVOID;
}

1;

=head1 NAME

CGI::Test::Page::HTML - A HTML page reply

=head1 SYNOPSIS

 # Inherits from CGI::Test::Page::Real

=head1 DESCRIPTION

This class represents an HTTP reply containing C<text/html> data.
When testing CGI scripts, this is usually what one gets back.

=head1 INTERFACE

The interface is the same as the one described in L<CGI::Test::Page::Real>,
with the following addition:

=over 4

=item C<tree>

Returns the root of the HTML tree of the page content, as an
HTML::Element node.

=back

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test::Page::Real(3), HTML::Element(3).

=cut

