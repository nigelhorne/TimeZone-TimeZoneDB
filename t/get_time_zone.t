#!perl -wT

use warnings;
use strict;
use Test::Most tests => 5;
use Geo::Location::Point 0.07;	# FIXME: 0.08

BEGIN {
	use_ok('TimeZone::TimeZoneDB');
}

TZ: {
	SKIP: {
		if(!$ENV{'TIMEZONEDB_KEY'}) {
			diag('Set TIMEZONEDB_KEY for your API key to timezonedb.com');
			skip('Set TIMEZONEDB_KEY for your API key to timezonedb.com', 4);
		} elsif(!-e 't/online.enabled') {
			diag('Test requires Internet access');
			skip('Test requires Internet access', 4);
		}

		my $tzdb = new_ok('TimeZone::TimeZoneDB' => [ key => $ENV{'TIMEZONEDB_KEY'} ]);
		# Timezone of Ramsgate
		my $tz = $tzdb->get_time_zone({ latitude => 51.34, longitude => 1.42 });

		if($ENV{'TEST_VERBOSE'}) {
			diag(Data::Dumper->new([$tz])->Dump());
		}

		cmp_ok($tz->{'zoneName'}, 'eq', 'Europe/London', 'Ramsgate is in the UK timezone');

		my $location = new_ok('Geo::Location::Point' => [ latitude => 51.34, longitude => 1.42 ]);
		$tz = $tzdb->get_time_zone($location);

		if($ENV{'TEST_VERBOSE'}) {
			diag(Data::Dumper->new([$tz])->Dump());
		}

		cmp_ok($tz->{'zoneName'}, 'eq', 'Europe/London', 'Ramsgate is in the UK timezone');
	}
}