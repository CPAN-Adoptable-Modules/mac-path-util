# $Id$

use Test::More tests => 2;

use Mac::Path::Util;

my $Startup = 'Otter';

my $util = Mac::Path::Util->new();
isa_ok( $util, 'Mac::Path::Util' );

my $startup = $util->_get_startup;
is( $startup, $Startup );
