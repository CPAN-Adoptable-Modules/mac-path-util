# $Id$
use ExtUtils::MakeMaker;
	
sub ExtUtils::MM_Any::test_via_harness
		{
		my($self, $perl, $tests) = @_;

		return qq|\t$perl "-MTest::Manifest" | .
			qq|"-e" "run_t_manifest(\$(TEST_VERBOSE), '\$(INST_LIB)', | .
			qq|'\$(INST_ARCHLIB)')"\n|;
		}
	
WriteMakefile(
    'NAME'		    => 'Mac::Path::Util',
	'VERSION_FROM'  => 'lib/Util.pm',
	
    'PM'            => {
     	'lib/Util.pm'         => '$(INST_LIBDIR)/Util.pm',
    	},

	'PREREQ_PM' => {
		'File::Find::Rule'  => '0',
		'Test::Data'        => '0',
		'Test::Manifest'    => '0.9',
		'Test::More'        => '0',
		'Test::Pod'         => '0.72',
		'Test::Prereq'      => '0.18',
		},

	'MAN3PODS'		=> {
		'lib/Util.pm'    => '$(INST_MAN3DIR)/Mac::Path::Util.3',
		},
		    	
	clean => { FILES => 'Mac-Path-Util' },
	);
