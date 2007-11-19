# $Id$
use ExtUtils::MakeMaker;
	
require 5.006;

eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'	       => 'Mac::Path::Util',
 	'ABSTRACT'     => 'convert between darwin and Mac paths';

   'VERSION_FROM'  => 'lib/Util.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	
    'PM'        => {
	    'lib/Util.pm'         => '$(INST_LIBDIR)/Util.pm',
		},

    'PREREQ_PM' => {
		'Test::Data'        => '0',
		'Test::More'        => '0',
		},

    'MAN3PODS'  => {
		'lib/Util.pm'    => '$(INST_MAN3DIR)/Mac::Path::Util.3',
		},
	    	
    clean => { FILES => 'Mac-Path-Util-*' },
);
