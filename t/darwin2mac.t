# $Id$
use strict;

use vars qw(@pairs);

BEGIN {
	@pairs = (
		[ qw(/Users/brian Otter:Users:brian) ],
		[ qw(brian :brian) ],
		[ qw(brian/Dev/Mac :brian:Dev:Mac) ],
		[ qw(/Volumes/CPAN/brian/Dev/Mac CPAN:brian:Dev:Mac) ],
		);
	}
	
use Test::More tests => 2 * scalar @pairs;
use Test::Data qw(Scalar);

use Mac::Path::Util;

foreach my $pair ( @pairs )
	{
	# white box test
	my $hash   = { starting_path => $pair->[0] };
	bless $hash, 'Mac::Path::Util';
	my $result = $hash->_darwin2mac;

	is( $result, $pair->[1] );
	
	# black box test
	my $path = Mac::Path::Util->new( $pair->[0] );
	if( $path->type eq Mac::Path::Util::DONT_KNOW )
		{
		undef_ok( $path->mac_path );
		next;
		}
	
	is( $path->mac_path, $pair->[1] );
	}
	

	
