#
# $Id: env.t,v 0.1 2001/03/31 10:54:03 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: env.t,v $
# Revision 0.1  2001/03/31 10:54:03  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use CGI::Test;

print "1..15\n";

my $SERVER = "some-server";
my $PORT = 18;
my $BASE = "http://${SERVER}:${PORT}/cgi-bin";

my $ct = CGI::Test->make(
	-base_url	=> $BASE,
	-cgi_dir	=> "t/cgi",
);

ok 1, defined $ct;

my $PATH_INFO = "path/info";
my $QUERY = "query=1";
my $USER = "ram";

my $page = $ct->GET("$BASE/printenv/${PATH_INFO}?${QUERY}", $USER);
ok 2, !$page->is_error;
ok 3, length $page->raw_content;

my %V;
parse_content(\%V, $page->raw_content_ref);

ok 4, $V{SCRIPT_NAME} eq "/cgi-bin/printenv";
ok 5, $V{SERVER_PORT} == $PORT;
ok 6, $V{REQUEST_METHOD} eq "GET";
ok 7, $V{SCRIPT_FILENAME} eq "t/cgi/printenv";
ok 8, $V{PATH_INFO} eq "/$PATH_INFO";
ok 9, $V{QUERY_STRING} eq $QUERY;
ok 10, $V{REMOTE_USER} eq $USER;
ok 11, $V{HTTP_USER_AGENT} eq "CGI::Test";

my $AGENT = "LWP::UserAgent";
my $EXTRA = "is set";
$page->delete;

my $ct2 = CGI::Test->make(
	-base_url	=> $BASE,
	-cgi_dir	=> "t/cgi",
	-cgi_env	=> {
		EXTRA_IMPORTANT_VARIABLE	=> $EXTRA,
		HTTP_USER_AGENT				=> $AGENT,
		SCRIPT_FILENAME				=> "foo",
	},
);

$page = $ct2->GET("$BASE/printenv");
parse_content(\%V, $page->raw_content_ref);

ok 12, $V{SCRIPT_NAME} eq "/cgi-bin/printenv";
ok 13, $V{HTTP_USER_AGENT} eq $AGENT;
ok 14, $V{EXTRA_IMPORTANT_VARIABLE} eq $EXTRA;
ok 15, !exists $V{REMOTE_USER};
$page->delete;

exit 0;		## DONE

sub parse_content {
	my ($h, $cref) = @_;
	%$h = ();
	foreach my $l (split /\n/, $$cref) {
		my ($k, $v) = split / = /, $l;
		$h->{$k} = $v;
	}
}

