# $Id$
package Mac::Path::Util;
use strict;

use base qw(Exporter);
use vars qw(@EXPORT_OK %EXPORT_TAGS);

use Cwd qw(getcwd);
use Exporter;

@EXPORT_OK   = qw(DARWIN MACOS);
%EXPORT_TAGS = (
	'system' => [ qw(DARWIN MACOS) ],
	);

my $Startup;

=head1 NAME

Mac::Path::Util - convert between darwin and Mac paths

=head1 SYNOPSIS

	use Mac::Path::Util;

	my $path     = Mac::Path::Util->new( "/Users/foo/file.txt" );
	my $mac_path = $path->mac_path;

=head1 DESCRIPTION

THIS IS ALPHA SOFTWARE.  SOME THINGS ARE NOT FINISHED.

Convert between darwin (unix) and Mac file paths.

This is not as simple as changing the directory separator.
The Mac path has the volume name in it, whereas the darwin
path leaves of the startup volume name because it is mounted
as /.

Colons ( ":" ) in the darwin path become / in the Mac path, and forward
slashes in the Mac path become colons in the darwin path.

Mac paths do not have a leading directory separator for absolute
paths.

Normally, Mac paths that end in a directory name have a trailing
colon, but this module cannot necessarily verify that since you
may want to convert paths.

=head2 Methods

=over 4

=cut

use constant DARWIN    => 'darwin';
use constant MACOS     => 'macos';

use constant DONT_KNOW => "Don't know";
use constant BAD_PATH  => "Bad Path";

use constant TRUE      => 'true';
use constant FALSE     => 'false';

use constant LOCAL     => 'local';
use constant REMOTE    => 'remote';

=item new( PATH [, HASH ] )


The optional anonymous hash can have these values:

	type      DARWIN or MACOS (explicitly state which sort of path
                 with these symbolic constants)
	startup   the name of the startup volume (if not defined, tries to use
                 the startup volume on the local machine)

=cut

sub new
	{
	my $class = shift;
	my $path  = shift;
	my $args  = shift;

	my $type  = DONT_KNOW 
		unless ( $args->{type} eq DARWIN or $args->{type} eq MACOS );

	my $self = {
		starting_path => $path,
		type          => $type,
		path          => $path,
		};

	bless $self, $class;

	$self->{startup} = $args->{startup} || undef;

	$self->_identify;

	return if $self->{type} eq BAD_PATH;

	# we know that there is at least one colon in the path
	# if the type is MACOS
	if( $self->type eq MACOS )
		{
		$self->{mac_path} = $self->path;

		# absolute paths do not start with colons
		if( index( $self->path, 0, 1 ) ne ":" )
			{
			my( $volume )= $self->path =~ m/^(.+?):/g;

			$self->{volume} = $volume;
			}
		else
			{
			$self->{volume}  = $self->_get_startup;
			$self->{startup} = $self->volume 
				if $self->_is_startup( $self->{volume} ) eq TRUE;
			}
		}
	elsif( $self->type eq DARWIN )
		{
		$self->{darwin_path} = $self->path;

		if( index( $self->path, 0, 1 ) eq "/" )
			{
			$self->{volume} = $self->path =~ m|^/Volumes/(.*?)/?|g;
			}

		unless( defined $self->volume )
			{
			$self->{volume}  = $self->_get_startup;
			$self->{startup} = $self->volume 
				if $self->_is_startup( $self->{volume} ) eq TRUE;
			}
			
		$self->_darwin2mac;
		}


	return $self;
	}

=back

=head2 Accessor methods

=over 4

=item type

=item path

=item volume

=item startup

=item mac_path

=item darwin_path

=cut

sub type        { return $_[0]->{type}        }
sub path        { return $_[0]->{path}        }
sub volume      { return $_[0]->{volume}      }
sub startup     { return $_[0]->{startup}     }
sub mac_path    { return $_[0]->{mac_path}    }
sub darwin_path { return $_[0]->{darwin_path} }

sub _d2m_trans
	{
	my $name = shift;

	$name =~ tr/:/\000/;
	$name =~ tr|/|:|;
	$name =~ tr|\000|/|;

	return $name;
	}

sub _darwin2mac
	{
	my $self = shift;

	my $name = $self->{starting_path};

	$self->{mac_path} = do {
		# is this a relative url?
		if(    substr( $name, 0, 1 ) ne "/" )
			{
			my $path = ":" . _d2m_trans( $name );
			$path;
			}
		# is this an absolute url with another Volume?
		elsif( $name =~ m|^/Volumes/([^/]+)(/.*)| )
			{
			my $volume = $1;
			my $path   = $2;

			$path = _d2m_trans( $path );

			my $abs = $volume .  $path;
			}
		# absolute path off of startup volume
		elsif( substr( $name, 0, 1 ) eq "/" )
			{
			my $volume = $self->_get_startup;

			my $path = _d2m_trans( $name );

			my $abs = $volume . $path;
			}
		};
	
	return $self->{mac_path};
	}

sub _mac2darwin
	{
	my $self = shift;
	my $name = shift;

	$name =~ tr|/|\000|;
	$name =~ tr|:|/|;
	$name =~ tr|\000|:|;

	return $name;
	}

sub _identify
	{
	my $self = shift;

	my $colons  = $self->{starting_path} =~ tr/://;
	my $slashes = $self->{starting_path} =~ tr|/||;

	if(    $colons == 0 and $slashes == 0 )
		{
		$self->{type} = DONT_KNOW;
		}
	elsif( $colons != 0 and $slashes == 0 )
		{
		$self->{type} = MACOS;
		}
	elsif( $colons == 0 and $slashes != 0 )
		{
		$self->{type} = DARWIN;
		}
	elsif( $colons != 0 and $slashes != 0 )
		{
		$self->{type} = DONT_KNOW;
		}

	}

sub clear_startup
	{
	my $self = shift;

	delete $self->{startup} if ref $self;
	$Startup = undef;
	}

sub _get_startup
	{
	my $self = shift;
	
	return $self->startup if defined $self->startup;
	return $Startup if defined $Startup;

	return unless eval { require Mac::AppleScript };

	my $script = "return path to startup disk as string";

	my $volume = Mac::AppleScript::RunAppleScript( $script );
	$volume =~ s/^"|"$//g;
	$volume =~ s/:$//g;

	#print STDERR "I think the startup volume is [$volume]\n";

	$Startup = $self->{startup} = $volume;

	return $volume;
	}

sub _is_startup
	{
	my $self = shift;
	my $name = shift;

	$name =~ s/"/\\"/g;

	$self->_get_startup unless defined $self->startup;
	
	$name eq $Startup ? TRUE : FALSE;
	}

=back

=head1 AUTHOR

brian d foy, E<gt>bdfoy@cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2002, brian d foy, All rights reserved

You may use this package under the same terms as Perl itself

=cut

"See why 1984 won't be like 1984";
