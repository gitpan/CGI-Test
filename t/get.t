#
# $Id: get.t,v 0.1 2001/03/31 10:54:03 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: get.t,v $
# Revision 0.1  2001/03/31 10:54:03  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use CGI::Test;

print "1..13\n";

my $BASE = "http://server:18/cgi-bin";

my $ct = CGI::Test->make(
	-base_url	=> $BASE,
	-cgi_dir	=> "t/cgi",
);

ok 1, defined $ct;

my $page = $ct->GET("$BASE/getform");
ok 2, !$page->is_error;

my $form = $page->forms->[0];
ok 3, $form->method eq "GET";
my @submit = $form->submits_named("Send");
ok 4, @submit == 1;

my $months = $form->widget_by_name("months");
$months->select("Jan");

my $send = $form->submit_by_name("Send");
my $page2 = $send->press;
ok 5, !$page2->is_error;

ok 6, !$page2->is_error;
ok 7, $page2->form_count == 1;
my $form2 = $page2->forms->[0];

@submit = $form2->submits_named("Send");
ok 8, @submit == 1;
ok 9, $form2->method eq "GET";
ok 10, $form2->enctype !~ /^multipart/;

my $months2 = $form2->widget_by_name("months");
ok 11, $months2->is_selected("Jul");
ok 12, $months2->is_selected("Jan");
ok 13, !$months2->is_selected("Feb");

