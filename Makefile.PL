use strict;
use warnings;

use ExtUtils::MakeMaker;
use Getopt::Long;	# Technique inspired by IO::Lambda
use IO::Socket::INET;

my $online_tests;

if($ENV{AUTHOR_TESTING}) {
	$online_tests = are_online();
} else {
	Getopt::Long::GetOptions('online-tests!' => \$online_tests);

	if(!defined($online_tests)) {
		$online_tests = are_online();
	}
	if(!$online_tests) {
		print "On-line tests have been disabled\n";
		$online_tests = 0;
	}
}

my $test_requires = {
	'autodie' => 0,
	'Geo::Location::Point' => 0.08,
	'IPC::System::Simple' => 0,	# http://www.cpantesters.org/cpan/report/0b994acc-7a03-11e8-a944-5f7713bf8fb6
	'Test::Carp' => 0,
	'Test::Compile' => 0,
	'Test::DescribeMe' => 0,
	'Test::MockModule' => 0,
	'Test::Most' => 0,
	'Test::Needs' => 0,
	'Test::NoWarnings' => 0,
	'WWW::RT::CPAN' => 0
};

if($online_tests) {
	open(my $enabled, '>', 't/online.enabled') || die "Can't touch t/online.enabled $!";
	close($enabled) || die "Can't touch t/online.enabled $!";
	$test_requires->{'Test::LWP::UserAgent'} = 0;
} else {
	unlink('t/online.enabled');
}

my $dist = {
	COMPRESS => 'gzip -9f',	# Compress tarball using gzip
	SUFFIX => 'gz',	# File suffix for tarball
};

if($^O eq 'darwin') {
	$dist->{'TAR'} = 'gtar';
}

WriteMakefile(
	NAME		=> 'TimeZone::TimeZoneDB',
	AUTHOR		=> q{Nigel Horne <njh@bandsman.co.uk>},
	VERSION_FROM	=> 'lib/TimeZone/TimeZoneDB.pm',
	ABSTRACT_FROM	=> 'lib/TimeZone/TimeZoneDB.pm',
	((defined($ExtUtils::MakeMaker::VERSION) &&
	 ($ExtUtils::MakeMaker::VERSION >= 6.3002))
	  ? ('LICENSE'=> 'GPL')
	  : ()),
	PL_FILES	=> {},
	TEST_REQUIRES => $test_requires,
	PREREQ_PM => {
		'CHI' => 0,
		'Encode' => 0,
		'ExtUtils::MakeMaker' => 6.64,	# for TEST_REQUIRES
		'JSON::MaybeXS' => 0,
		'LWP::UserAgent' => 0,
		'LWP::Protocol::https' => 0,
		'Object::Configure' => 0,
		'Params::Get' => 0,
		'Scalar::Util' => 0,
		'Time::HiRes' => 0,
		'URI' => 0,
	}, dist => $dist,
	clean		=> { FILES => 'TimeZone-TimeZoneDB-*' },
	META_MERGE => {	# https://perldoc.perl.org/CPAN::Meta::Spec
		'meta-spec' => { version => 2 },
		resources => {
			repository => {
				type => 'git',
				url => 'git://github.com/nigelhorne/TimeZone-TimeZoneDB.git',
				web => 'https://github.com/nigelhorne/TimeZone-TimeZoneDB',
				repository => 'https://github.com/nigelhorne/TimeZone-TimeZoneDB',
			}, bugtracker => {
				# web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=TimeZone-TimeZoneDB',
				web => 'https://github.com/nigelhorne/TimeZone-TimeZoneDB/issues',
				url => 'https://github.com/nigelhorne/TimeZone-TimeZoneDB/issues',
				mailto => 'bug-TimeZone-TimeZoneDB@rt.cpan.org'
			}
		},
	},
	MIN_PERL_VERSION	=> '5.6.2'	# Probably would work, but never tested on earlier versions than this
);

sub are_online
{
	return 0 if($ENV{'NO_NETWORK_TESTING'} || $ENV{'CIRCLECI'} || $ENV{'TRAVIS_PERL_VERSION'} || $ENV{'AUTOMATED_TESTING'} || $ENV{'NONINTERACTIVE_TESTING'} || (!-t STDIN));

	if(my $s = IO::Socket::INET->new(
		PeerAddr => 'timezonedb.com:443',
		Timeout => 10
	)) {
		if($ENV{'PERL_MM_USE_DEFAULT'}) {
			close($s);
			return 0;	# Don't overload the server by default
		}

		print <<EOF;

You appear to be directly connected to the Internet.  I have some tests
that try to query timezonedb.com.

EOF
		close($s);

		# Timeout inspired by Mail::IMAPClient
		my $rc;
		eval {
			local $SIG{ALRM} = sub { die 'alarm' };
			alarm(60);
			$rc = prompt('Do you want to enable these tests?', 'y') =~ /^y/i ? 1 : 0;
			alarm(0);
		};
		if($@) {
			print "\n";
			return 1;	# The default is 'y'
		}
		return $rc;
	}
	print "On-line tests disabled because I couldn't detect an Internet connexion\n";
	return 0;
}
