# $Id$
use ExtUtils::MakeMaker;
	
eval "use Test::Manifest";

unless( $@ )
	{
	* ExtUtils::MM_Any::test_via_harness = sub
		{
		my($self, $perl, $tests) = @_;
		
		return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
		}
	}
	
WriteMakefile(
    'NAME'	    => 'Mac::Path::Util',
    'VERSION_FROM'  => 'lib/Util.pm',
	
    'PM' => {
	    'lib/Util.pm'         => '$(INST_LIBDIR)/Util.pm',
    },

    'PREREQ_PM' => {
	'Test::Data'        => '0',
	'Test::More'        => '0',
    },

    'MAN3PODS'		=> {
	'lib/Util.pm'    => '$(INST_MAN3DIR)/Mac::Path::Util.3',
    },
	    	
    clean => { FILES => 'Mac-Path-Util-*' },
);
