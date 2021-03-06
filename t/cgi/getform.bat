@rem = '--*-Perl-*--
@echo off
if "%OS%" == "Windows_NT" goto WinNT
perl -x -S "%0" %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
:WinNT
perl -x -S %0 %*
if NOT "%COMSPEC%" == "%SystemRoot%\system32\cmd.exe" goto endofperl
if %errorlevel% == 9009 echo You do not have Perl in your PATH.
if errorlevel 1 goto script_failed_so_exit_with_non_zero_val 2>nul
goto endofperl
@rem ';
#!perl
#line 15

use CGI qw/:standard :no_xhtml/;

$\ = "\n";

print header;
my $method = param("method") || request_method();
my $action = param("action") || url();
print start_html("$method form"), h1("$method form");
print start_form(
	-method		=> $method eq "POST" ? "POST" : "GET",
	-enctype	=> param("enctype") eq "M" ?
			"multipart/form-data" : "application/x-www-form-urlencoded",
	-action		=> $action,
);

my $counter = param("counter") + 1;
param("counter", $counter);
print hidden("counter");
print hidden("enctype");

print "Title: ", radio_group(
	-name		=> "title",
	-values		=> [qw(Mr Ms Miss)],
	-default	=> 'Mr'), br;

print "Name: ", textfield("name"), br;

print "Skills: ", checkbox_group(
	-name		=> "skills",
	-values		=> [qw(cooking drawing teaching listening)],
	-defaults	=> ['listening'],
), br;

print "New here: ", checkbox(
	-name		=> "new",
	-checked	=> 1,
	-value		=> "ON",
	-label		=> "click me",
), br;


print "Color: ", popup_menu(
	-name		=> "color",
	-values		=> [qw(white black green red blue)],
	-default	=> "white",
), br;

print "Note: ", textarea("note"), br;

print "Prefers: ", scrolling_list(
	-name		=> "months",
	-values		=> [qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)],
	-size		=> 5,
	-multiple	=> 1,
	-default	=> [qw(Jul)],
), br;

print "Password: ", password_field(
	-name		=> "passwd",
	-size		=> 10,
	-maxlength	=> 15,
), br;

print "Portrait: ", filefield(
	-name		=> "portrait",
	-size		=> 30,
	-maxlength	=> 80,
), br;

print p(
	reset(),
	defaults("default"),
	submit("Send"),
	image_button(
		-name	=> "img_send",
		-alt	=> "GO!",
		-src	=> "go.png",
		-width	=> 50,
		-height	=> 30,
		-border	=> 0,
	),
);

print end_form;
print end_html;


__END__
:endofperl
