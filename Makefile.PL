#
# $Id: Makefile.PL,v 0.1 2001/03/31 10:54:01 ram Exp $
#
#  Copyright (c) 2001, Raphael Manfredi
#  
#  You may redistribute only under the terms of the Artistic License,
#  as specified in the README file that comes with the distribution.
#
# HISTORY
# $Log: Makefile.PL,v $
# Revision 0.1  2001/03/31 10:54:01  ram
# Baseline for first Alpha release.
#
# $EndLog$
#

use ExtUtils::MakeMaker;
eval q(use Carp::Datum::MakeMaker;);

WriteMakefile(
    'NAME'	=> 'CGI::Test',
    'VERSION_FROM' => 'Test.pm', # finds $VERSION
	'PREREQ_PM' => {
		'CGI'					=> '0',
		'Carp::Datum'			=> '0',
		'Digest::MD5'			=> '0',
		'Getargs::Long'			=> '0.103',
		'Log::Agent'			=> '0.207',
		'URI'					=> '1.10',
		'HTTP::Status'			=> '0',
		'HTML::TreeBuilder'		=> '0',
		'File::Temp'			=> '0',
		'File::Spec'			=> '0',
		'Storable'				=> '1.000',
	},
    'LIBS'	=> [''],		# e.g., '-lm' 
    'DEFINE'	=> '',		# e.g., '-DHAVE_SOMETHING' 
    'INC'	=> '',			# e.g., '-I/usr/include/other' 
);

