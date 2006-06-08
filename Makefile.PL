# $Id$
use ExtUtils::MakeMaker;
	
eval "use Test::Manifest 1.14";
	
WriteMakefile(
    'NAME'	        => 'Mac::Path::Util',
    'VERSION_FROM'  => 'lib/Util.pm',
	
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
