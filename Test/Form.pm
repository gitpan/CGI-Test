#
# $Id: Form.pm,v 0.1 2001/03/31 10:54:01 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Form.pm,v $
# Revision 0.1  2001/03/31 10:54:01  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use strict;

package CGI::Test::Form;

#
# Class interfacing with the content of a <FORM> tag, which comes from
# a CGI::Test::Page object.  The tree nodes we are playing with here are
# direct pointers into the node of the page object.
#

use Carp::Datum;
use Log::Agent;

#
# ->make
#
# Creation routine
#
sub make {
	DFEATURE my $f_;
	my $self = bless {}, shift;
	my ($node, $page) = @_;

	DREQUIRE $node->isa("HTML::Element");
	DREQUIRE $page->isa("CGI::Test::Page");
	DREQUIRE $node->tag eq "form";

	$self->{tree} = $node;		# <FORM> is the root node of the tree
	$self->{page} = $page;

	$self->{enctype} = $node->attr("enctype") ||
		"application/x-www-form-urlencoded";
	$self->{method} = uc $node->attr("method") || "POST";

	foreach my $attr (qw(action name accept accept-charset)) {
		my $oattr = $attr;
		$oattr =~ s/-/_/g;
		my $value = $node->attr($attr);
		$self->{$oattr} = $value if defined $value;
	}

	#
	# Although ACTION is now required in newer HTML DTDs, it was optional
	# in HTML 2.0 and defaults to the base URI of the document.
	#

	$self->{action} = $page->uri->as_string unless exists $self->{action};

	return DVAL $self;
}

#
# Attribute access
#

sub tree			{ $_[0]->{tree} }
sub page			{ $_[0]->{page} }

sub enctype			{ $_[0]->{enctype} }
sub action			{ $_[0]->{action} }
sub method			{ $_[0]->{method} }
sub name			{ $_[0]->{name} }
sub accept			{ $_[0]->{accept} }
sub accept_charset	{ $_[0]->{accept_charset} }

#
# Lazy attribute access
#

sub buttons		{ $_[0]->{buttons}    || $_[0]->_xtract("buttons") }
sub inputs		{ $_[0]->{inputs}     || $_[0]->_xtract("inputs") }
sub menus		{ $_[0]->{menus}      || $_[0]->_xtract("menus") }
sub radios		{ $_[0]->{radios}     || $_[0]->_xtract("radios") }
sub checkboxes	{ $_[0]->{checkboxes} || $_[0]->_xtract("checkboxes") }
sub hidden		{ $_[0]->{hidden}     || $_[0]->_xtract("hidden") }
sub widgets		{ $_[0]->{widgets}    || $_[0]->_xtract("widgets") }

#
# Second-order lazy attributes
#

sub submits     { $_[0]->{submits}    || ($_[0]->{submits} = $_[0]->_submits) }

sub radio_groups	{ $_[0]->radios     && $_[0]->{radio_groups} }
sub checkbox_groups	{ $_[0]->checkboxes && $_[0]->{checkbox_groups} }


#
# Expanded lists -- syntactic sugar
#

sub button_list			{ @{$_[0]->buttons} }
sub input_list			{ @{$_[0]->inputs} }
sub menu_list			{ @{$_[0]->menus} }
sub radio_list			{ @{$_[0]->radios} }
sub checkbox_list		{ @{$_[0]->checkboxes} }
sub hidden_list			{ @{$_[0]->hidden} }
sub widget_list			{ @{$_[0]->widgets} }
sub submit_list			{ @{$_[0]->submits} }

#
# By parameter-name n-n widget access (one widget returned for each asked)
#

sub button_by_name		{ my $s = shift; $s->_by_name($s->buttons, @_) }
sub input_by_name		{ my $s = shift; $s->_by_name($s->inputs, @_) }
sub menu_by_name		{ my $s = shift; $s->_by_name($s->menus, @_) }
sub radio_by_name		{ my $s = shift; $s->_by_name($s->radios, @_) }
sub checkbox_by_name	{ my $s = shift; $s->_by_name($s->checkboxes, @_) }
sub hidden_by_name		{ my $s = shift; $s->_by_name($s->hidden, @_) }
sub widget_by_name		{ my $s = shift; $s->_by_name($s->widgets, @_) }
sub submit_by_name		{ my $s = shift; $s->_by_name($s->submits, @_) }

#
# By parameter-name 1-n widget access (many widgets may be returned, one asked)
#

sub buttons_named		{ my $s = shift; $s->_all_named($s->buttons, @_) }
sub inputs_named		{ my $s = shift; $s->_all_named($s->inputs, @_) }
sub menus_named			{ my $s = shift; $s->_all_named($s->menus, @_) }
sub radios_named		{ my $s = shift; $s->_all_named($s->radios, @_) }
sub checkboxes_named	{ my $s = shift; $s->_all_named($s->checkboxes, @_) }
sub hidden_named		{ my $s = shift; $s->_all_named($s->hidden, @_) }
sub widgets_named		{ my $s = shift; $s->_all_named($s->widgets, @_) }
sub submits_named		{ my $s = shift; $s->_all_named($s->submits, @_) }

#
# Convenience routines around ->_matching().
#

sub buttons_matching	{ my $s = shift; $s->_matching($s->buttons, @_) }
sub inputs_matching		{ my $s = shift; $s->_matching($s->inputs, @_) }
sub menus_matching		{ my $s = shift; $s->_matching($s->menus, @_) }
sub radios_matching		{ my $s = shift; $s->_matching($s->radios, @_) }
sub checkboxes_matching	{ my $s = shift; $s->_matching($s->checkboxes, @_) }
sub hidden_matching		{ my $s = shift; $s->_matching($s->hidden, @_) }
sub widgets_matching	{ my $s = shift; $s->_matching($s->widgets, @_) }
sub submits_matching	{ my $s = shift; $s->_matching($s->submits, @_) }

#
# ->reset
#
# Reset form state, restoring all the widget controls to the value they
# had upon entry.
#
sub reset {
	DFEATURE my $f_;
	my $self = shift;

	foreach my $w ($self->widget_list) {
		$w->reset_state;
	}
	return DVOID;
}

#
# ->submit
#
# Submit this form.
# Returns resulting CGI::Test::Page.
#
sub submit {
	DFEATURE my $f_;
	my $self = shift;

	my $method = $self->method;
	my $input = $self->_output;		# Input to the request we're about to make
	my $action = $self->_action_url;
	my $page = $self->page;
	my $server = $page->server;
	my $result;

	if ($method eq "GET") {
		logconfess "GET requests only allowed URL encoding, not %s",
			$input->mime_type
			unless $input->mime_type eq "application/x-www-form-urlencoded";

		$action->query($input->data);
		$result = $server->GET($action->as_string, $page->user);
	}
	elsif ($method eq "POST") {
		$result = $server->POST($action->as_string, $input, $page->user);
	}
	else {
		logconfess "unsupported method $method for FORM action";
	}

	return DVAL $result;
}

#
# ->_xtract
#
# Widget extraction routine: traverse the <FORM> tree and create an instance
# of CGI::Test::Form::Widget per encountered widget.  The dynamic type depends
# on the widget type, e.g. a button creates a CGI::Test::Form::Widget::Button
# object.
#
# Widgets are also sorted by type, and stored as object attribute:
#
#   buttons         all buttons
#	inputs        	text area, text fields, password fields
#	menus		    popup menus
#	radios		  	radio buttons
#	checkboxes	  	all checkboxes
#	hidden          all hidden fields
#	widgets         all widgets, whatever their type.
#
# The special attribute `radio_groups' is only built when there is at least
# one radio button.
#
# Although we extract ALL the widgets, caller is only interested in a
# specific list, given in $which.  Therefore, returns a list ref on that
# particular set.
#
sub _xtract {
	DFEATURE my $f_;
	my $self = shift;
	my ($which) = @_;

	#
	# We may not create an instance of all those classes, but the cost of
	# lazily requiring them would probably outweigh the cost of loading
	# them once and for all, on reasonably sized forms.
	#

	require CGI::Test::Form::Widget::Button::Submit;
	require CGI::Test::Form::Widget::Button::Reset;
	require CGI::Test::Form::Widget::Button::Image;
	require CGI::Test::Form::Widget::Button::Plain;
	require CGI::Test::Form::Widget::Input::Text_Field;
	require CGI::Test::Form::Widget::Input::Text_Area;
	require CGI::Test::Form::Widget::Input::Password;
	require CGI::Test::Form::Widget::Input::File;
	require CGI::Test::Form::Widget::Menu::List;
	require CGI::Test::Form::Widget::Menu::Popup;
	require CGI::Test::Form::Widget::Box::Radio;
	require CGI::Test::Form::Widget::Box::Check;
	require CGI::Test::Form::Widget::Hidden;

	#
	# Initiate traversal to locate all widgets nodes.
	#

	my %is_widget = map { $_ => 1 } qw(input textarea select button isindex);
	my @wg = $self->tree->look_down(
		sub { $is_widget{$_[0]->tag} }
	);

	#
	# Initialize all lists to be empty
	#

	foreach my $attr (
		qw(buttons inputs radios checkboxes hidden menus widgets)
	) {
		$self->{$attr} = [];
	}

	#
	# And now sort them out.
	#

	my %input = (	#  [ class name,		 attribute ]
		"submit"	=> ['Button::Submit',	 "buttons"],
		"reset"		=> ['Button::Reset',	 "buttons"],
		"image"		=> ['Button::Image',	 "buttons"],
		"text"		=> ['Input::Text_Field', "inputs"],
		"file"		=> ['Input::File',    	 "inputs"],
		"password"	=> ['Input::Password',   "inputs"],
		"radio"		=> ['Box::Radio',		 "radios"],
		"checkbox"	=> ['Box::Check',		 "checkboxes"],
		"hidden"	=> ['Hidden',			 "hidden"],
	);

	my %button = (	#  [ class name,		 attribute ]
		"submit"	=> ['Button::Submit',	 "buttons"],
		"reset"		=> ['Button::Reset',	 "buttons"],
		"button"	=> ['Button::Plain',	 "buttons"],
	);

	my $wlist = $self->{widgets};		# All widgets also inserted there

	foreach my $node (@wg) {
		my $tag = $node->tag;
		my ($class, $attr);
		my $hlookup;

		if ($tag eq "input") {
			$hlookup = \%input;
		}
		elsif ($tag eq "textarea") {
			($class, $attr) = ("Input::Text_Area", "inputs");
		}
		elsif ($tag eq "select") {
			$attr = "menus";
			$class = ($node->attr("multiple") || defined $node->attr("size")) ?
				"Menu::List" : "Menu::Popup";
		}
		elsif ($tag eq "button") {
			$hlookup = \%button;
		}
		elsif ($tag eq "isindex") {
			logwarn "ISINDEX is deprecated, ignoring %s", $node->starttag;
			next;
		}
		else {
			logconfess "reached tag '$tag': invalid tree look_down()?"
		}

		#
		# If $hlookup is defined, we need to look at the TYPE attribute
		# within the tag to determine the object to build.
		#
		# This handles <INPUT TYPE="xxx"> and <BUTTON TYPE="xxx">
		#
		
		if (defined $hlookup) {
			my $type = $node->attr("type");
			unless (defined $type) {
				logerr "missing TYPE indication in %s: %s",
					uc($tag), $node->starttag;
				next;
			}
			my $info = $hlookup->{lc($type)};
			unless (defined $info) {
				logerr "unknown TYPE '%s' in %s: %s",
					$type, uc($tag), $node->starttag;
				next;
			}

			($class, $attr) = @$info;
		}

		#
		# Create object of given class, insert into attribute list.
		# Objects will not keep a reference on the node, but will reference us.
		#

		my $obj = "CGI::Test::Form::Widget::$class"->make($node, $self);
		push @{$self->{$attr}}, $obj;
		push @$wlist, $obj;
	}

	#
	# Special handling for radio buttons: they need to be groupped, so that
	# selecting one automatically unselects others from the same group.
	#
	# Special handling for checkboxes: one may wish to get at a "group of
	# checkboxes" instead of an individual checkbox widget.
	#

	my $radios     = $self->{radios};
	my $checkboxes = $self->{checkboxes};

	if (@$radios) {
		require CGI::Test::Form::Group;
		$self->{radio_groups} = CGI::Test::Form::Group->make($radios);
	}
	if (@$checkboxes) {
		require CGI::Test::Form::Group;
		$self->{checkbox_groups} = CGI::Test::Form::Group->make($checkboxes);
	}

	#
	# Finally, return the list they asked for.
	#

	return DVAL $self->{$which}
}

#
# ->_by_name
#
# Access to widgets, by name, in an n-n fashion: one widget returned for
# each name asked, multiple names may be givem.
#
# Extract and return a list of widgets from a list, by comparing names.
# If no widget of corresponding name exists, returns undef.
#
# There is one returned element per requested name.
# When only one name is requested, either scalar or list context may be used.
#
# For widgets which may be groupped (e.g. radios or checkboxes), the item
# selected is the last one bearing that name within the form.
#
sub _by_name {
	DFEATURE my $f_;
	my $self = shift;
	my ($wlist, @names) = @_;

	VERIFY ref $wlist eq 'ARRAY';

	my %byname = map { $_->name => $_ } @$wlist;
	my @results = map { $byname{$_} } @names;

	if (@names == 1) {
		return DARY @results if wantarray;
		return DVAL $results[0];
	}

	return DARY @results;
}

#
# ->_all_named
#
# Access to widgets, by name, in a 1-n fashion: from one name, multiple widgets
# may be returned.
#
# Extract and return a list of widgets from a list, by comparing names.
# If no widget of corresponding name exists, returns an empty list.
# Otherwise returns the list of all widgets bearing that name.
# 
sub _all_named {
	DFEATURE my $f_;
	my $self = shift;
	my ($wlist, $name) = @_;

	VERIFY ref $wlist eq 'ARRAY';

	return DARY grep { $_->name eq $name } @$wlist;
}

#
# ->_matching
#
# Extract widgets from list via matching callback, invoked as:
#
#   callback($widget, $context)
#
# where $context is one of the select routine parameters.
# Returns list of widgets for which the callback returned true.
#
sub _matching {
	DFEATURE my $f_;
	my $self = shift;
	my ($wlist, $code, $context) = @_;

	VERIFY ref $wlist eq 'ARRAY';
	VERIFY ref $code eq 'CODE';

	return DARY grep { &$code($_, $context) } @$wlist;
}

#
# ->delete
#
# Done with this page, cleanup by breaking circular & multiple refs.
#
sub delete {
	DFEATURE my $f_;
	my $self = shift;

	$self->{node} = undef;
	$self->{page} = undef;

	delete $self->{submits};

	#
	# Handle lazy attributes.
	#

	if (ref $self->{widgets}) {
		#
		# Each widget has a reference on us, which must be cleared.
		#

		foreach my $w (@{$self->{widgets}}) {
			$w->delete;
		}

		#
		# All widget objects have two references from here: one through their
		# type list, and one through the general "widgets" list.  Simply
		# break the "widgets" list.
		#

		$self->{widgets} = undef;
	}

	$self->{radio_groups}->delete		if ref $self->{radio_groups};
	$self->{checkbox_groups}->delete	if ref $self->{checkbox_groups};

	return DVOID;
}

#
# ->_output
#
# Create a CGI::Test::Input object and fill it with all the submitable
# widgets.  That object can then generate the data to be used as input of
# the form's action URL, depending on the form's encoding type.
#
sub _output {
	DFEATURE my $f_;
	my $self = shift;

	my $enctype = $self->enctype;
	my $input;

	#
	# Create polymorphic form input object, holding this form's output.
	#
	# It's called "input" because its data are meant to be the input of the
	# target CGI script.
	#

	if ($enctype eq "multipart/form-data") {
		require CGI::Test::Input::Multipart;
		$input = CGI::Test::Input::Multipart->make();
	} else {
		logwarn "unknown FORM encoding type $enctype, using default"
			if $enctype ne "application/x-www-form-urlencoded";
		require CGI::Test::Input::URL;
		$input = CGI::Test::Input::URL->make();
	}

	#
	# Add all submitable widgets.
	#

	foreach my $w (
		$self->widgets_matching(sub { $_[0]->is_submitable })
	) {
		$input->add_widget($w);
	}

	return DVAL $input;
}

#
# ->_action_url
#
# Compute the action URL, which is what is going to be requested in response
# to a form submit.  It does not contain the query part.
#
# We force re-anchor to the server if the action URL is not tied to it
# explicitely (e.g. ACTION="/cgi-bin/foo").
#
sub _action_url {
	DFEATURE my $f_;
	my $self = shift;

	my $uri = $self->page->uri;			# The URL that generated this form
	my $host_port = $uri->host_port;

	require URI;

	my $action = URI->new($self->action, "http");
	$action->scheme("http");
	$action->host_port($uri->host_port) unless defined $action->host_port;

	return DVAL $action;
}

#
# ->_submits
#
# Compute list of submit buttons.
# Returns ref to this list.
#
sub _submits {
	DFEATURE my $f_;
	my $self = shift;

	my @submit = $self->buttons_matching(sub { $_[0]->is_submit });

	return DVAL \@submit;
}

1;

=head1 NAME

CGI::Test::Form - Querying interface to CGI form widgets

=head1 SYNOPSIS

 my $form = $page->forms->[0];       # first form in CGI::Test::Page

 #
 # Querying interface, to access form widgets
 #

 my @buttons = $form->button_list;   # ->buttons would give list ref
 my $radio_listref = $form->radios;  # ->radios_list would give list

 my $passwd_widget = $form->input_by_name("password");
 my ($login, $passwd) = $form->input_by_name(qw(login password));

 my @menus = $form->widgets_matching(sub { $_[0]->is_menu });
 my @menus = $form->menu_list;       # same as line above

 my $rg = $form->radio_groups;       # a CGI::Test::Form::Group or undef

 #
 # <FORM> attributes, as defined by HTML 4.0
 #

 my $encoding = $form->enctype;
 my $action = $form->action;
 my $method = $form->method;
 my $name = $form->name;
 my $accept = $form->accept;
 my $accept_charset = $form->accept_charset;

 #
 # Miscellaneous
 #

 # Low-level, direct calls normally not needed
 $form->reset;
 my $new_page = $form->submit;

 # Very low-level access
 my $html_tree = $form->tree;        # HTML::Element form tree
 my $page = $form->page;             # Page containing this form

 #
 # Garbage collection -- needed to break circular references
 #

 $form->delete;

=head1 DESCRIPTION

The C<CGI::Test::Form> class provides an interface to the content of
the CGI forms.  Instances are automatically created by C<CGI::Test> when
it analyzes an HTML output from a GET/POST request and encounters such
beasts.

This class is really the basis of the C<CGI::Test> testing abilities:
it provides the necessary routines to query the CGI widgets present in the
form: buttons, input areas, menus, etc...  Queries can be made by type, and
by name.  There is also an interface to specifically access groupped widgets
like checkboxes and radio buttons.

All widgets returned by the queries are polymorphic objects, heirs of
C<CGI::Test::Form::Widget>.  If the querying interface can be compared to
the human eye, enabling you to locate a particular graphical item on the
browser screen, the widget interface can be compared to the mouse and keyboard,
allowing you to interact with the located graphical components.  Please
refer to L<CGI::Test::Form::Widget> for interaction details.

Apart from the widget querying interface, this class also offers a few
services to other C<CGI::Test> components, like handling of I<reset> and
I<submit> actions, which need not be used directly in practice.

Finally, it provides inspection of the <FORM> tag attributes (encoding
type, action, etc...) and, if you really need it, to the HTML tree of
the all <FORM> content.  This interface is based on the C<HTML::Element>
class, which represents a tree node.  The tree is shared with other
C<CGI::Test> components, it is not a private copy.  See L<HTML::Element> if
you are not already familiar with it.

If memory is a problem, you must be aware that circular references are
used almost everywhere within C<CGI::Test>.  Because Perl's garbage collector
cannot reclaim objects that are part of such a reference loop, you must
explicitely call the I<delete> method on C<CGI::Test::Form>.
Simply forgetting about the reference to that object is not enough.
Don't bother with it if your regression test scripts die quickly.

=head1 INTERFACE

The interface is mostly a querying interface.  Most of the routines return
widget objects, via lists or list references.  See L<CGI::Test::Form::Widget>
for details about the interface provided by widget objects, and the
classification.

The order of the widgets returned lists is the same as the order the widgets
appear in the HTML representation.

=head2 Type Querying Interface

There are two groups or routines: one group returns expanded lists, the
other returns list references.  They are listed in the table below.

The I<Item Polymorphic Type> column refers to the polymorphic dynamic
type of items held within the list: each item is guaranteed to at least
be of that type, but can be a descendant.  Types are listed in the
abridged form, and you have to prepend the string C<CGI::Test::Form::>
in front of them to get the real type.

 Expanded List  List Reference  Item Polymorphic Type
 -------------  --------------  ----------------------
 button_list    buttons         Widget::Button
 checkbox_list  checkboxes      Widget::Box::Check
 hidden_list    hidden          Widget::Hidden
 input_list     inputs          Widget::Input
 menu_list      menus           Widget::Menu
 radio_list     radios          Widget::Box::Radio
 submit_list    submits         Widget::Button::Submit
 widget_list    widgets         Widget

For instance:

    my @widgets = @{$form->widgets};     # heavy style
    my @widgets = $form->widget_list;    # light style

A given widget may appear in several lists, i.e.the above do not form a
partition over the widget set.  For instance, a submit button would appear
in the C<widget_list> (which lists I<all> widgets), in the C<button_list>
and in the C<submit_list>.

=head2 Name Querying Interface

Those routine take a name or a list of names, and return the widgets whose
parameter name is B<exactly> the given name (string comparison).  You may
query all widgets, or a particular class, like all buttons, or all input
fields.

There are two groups of routines:

=over 4

=item *

One group allows for multiple name queries, and returns a list of widgets,
one entry for each listed name.  Some widgets like radio buttons may have
multiple instances bearing the same name, and in that case only one is
returned.  When querying for one name, you are allowed to use scalar context:

    my  @hidden   = $form->hidden_by_name("foo", "bar");
    my ($context) = $form->hidden_by_name("context");
    my  $context  = $form->hidden_by_name("context");

When no widget (of that particular type) bearing the requested name is found,
C<undef> is returned for that particular slot, so don't blindly make method
calls on each returned value.

We shall call that group of query routines the B<by-name> group.

=item *

The other group allows for a single name query, but returns a list of all
the widgets (of some particular type when not querying the whole widget list)
bearing that name.

    my @hidden = $form->hidden_named("foo");

Don't assume that only radios and checkboxes can have multiple instances
bearing the same name.

We shall call that group of query routines the B<all-named> group.

=back

The available routines are listed in the table below.  Note that I<by-name>
queries are singular, because there is at most one returned widget per name
asked, whereas I<all-named> queries are plural, where possible.

The I<Item Polymorphic Type> column refers to the polymorphic dynamic
type of items held within the list: each defined item is guaranteed to at
least be of that type, but can be a descendant.  Types are listed in the
abridged form, and you have to prepend the string C<CGI::Test::Form::>
in front of them to get the real type.

 By-Name Queries   All-Named Queries  Item Polymorphic Type
 ----------------  -----------------  ----------------------
 button_by_name    buttons_named      Widget::Button
 checkbox_by_name  checkboxes_named   Widget::Box::Check
 hidden_by_name    hidden_named       Widget::Hidden
 input_by_name     inputs_named       Widget::Input
 menu_by_name      menus_named        Widget::Menu
 radio_by_name     radios_named       Widget::Box::Radio
 submit_by_name    submits_named      Widget::Button::Submit
 widget_by_name    widgets_named      Widget

=head2 Match Querying Interface

This is a general interface, which invokes a matching callback on each
widget of a particular category.  The signature of the matching routines is:

    my @matching = $form->widgets_matching(sub {code}, $arg);

and the callback is invoked as:

    callback($widget, $arg);

A widget is kept if, and only if, the callback returns true.  Be sure to
write your callback so that is only uses calls that apply to the particular
widget.  When you know you're matching on menu widgets, you can call
menu-specific features, but should you use that same callback for buttons,
you would get a runtime error.

Each matching routine returns a list of matching widgets.  Using the $arg
parameter is optional, and should be avoided unless you have no other choice,
so as to be as stateless as possible.

The following table lists the available matching routines, along with the
polymorphic widget type to be expected in the callback.  As usual, you must
prepend the string C<CGI::Test::Form::> to get the real type.

 Matching Routine     Item Polymorphic Type
 -------------------  ---------------------
 buttons_matching     Widget::Button
 checkboxes_matching  Widget::Box::Check
 hidden_matching      Widget::Hidden
 inputs_matching      Widget::Input
 menus_matching       Widget::Menu
 radios_matching      Widget::Box::Radio
 submits_matching     Widget::Button::Submit
 widgets_matching     Widget

For instance:

    my @menus = $form->widgets_matching(sub { $_[0]->is_menu });
    my @color = $form->widgets_matching(
        sub { $_[0]->is_menu && $_[0]->name eq "color" }
    );

is an inefficient way of saying:

    my @menus = $form->menu_list;
    my @color = $form->menus_matching(sub { $_[0]->name eq "color" });

and the latter can further be rewritten as:

    my @color = $form->menus_named("color");

=head2 Form Interface

This provides an interface to get at the attributes of the <FORM> tag.
For instance:

    my $enctype = $form->enctype;

to get at the encoding type of that particular form.
The following attributes are available:

    accept
    accept_charset
    action
    enctype
    method
    name

as defined by HTML 4.0.

=head2 Group Querying Interface

There are two kinds of widgets that are architecturally groupped, meaning
more that one instance of that widget can bear the same name: radio buttons
and checkboxes (although you may have a single standalone checkbox).

All radio buttons and checkboxes defined in a form are automatically
inserted into a group of their own, which is an instance of the
C<CGI::Test::Form::Group> class.  This class contains all the defined
groups for a particular kind.  The routines:

    checkbox_groups
    radio_groups

give you access to the C<CGI::Test::Form::Group> container.  Both routines
may return C<undef> when there is no checkbox or radio button in the form.
See L<CGI::Test::Form::Group> for its querying interface.

=head2 Memory Cleanup

You B<must> call the I<delete> method to break the circular references
if you wish to dispose of the object.

=head2 Internal Interface

The following routines are available internally:

=over 4

=item reset

Reset the form state, restoring all the controls to the value they
had upon entry.

=item submit

Submit the form, returning a C<CGI::Test::Page> reply.

=back

=head1 BUGS

There are documentation bugs, problably, and implementation bugs, improbably.

=head1 AUTHOR

Raphael Manfredi F<E<lt>Raphael_Manfredi@pobox.comE<gt>>

=head1 SEE ALSO

CGI::Test(3), CGI::Test::Form::Widget(3), CGI::Test::Form::Group(3),
CGI::Test::Page(3), HTML::Element(3).

=cut

