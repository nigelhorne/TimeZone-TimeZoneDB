#!perl -wT

use warnings;
use strict;
use Test::Most tests => 7;
use Geo::Location::Point 0.07;	# FIXME: 0.08

BEGIN {
	use_ok('TimeZone::TimeZoneDB');
}

TZ: {
	SKIP: {
		my $tzdb = new_ok('TimeZone::TimeZoneDB');

		if(!-e 't/online.enabled') {
			if(!defined($ENV{'TIMEZONEDB_KEY'})) {
				diag('Set TIMEZONEDB_KEY for your API key to timezonedb.com');
				skip('Set TIMEZONEDB_KEY for your API key to timezonedb.com', 5);
			} else {
				diag('Test requires Internet access');
				skip('Test requires Internet access', 5);
			}
		}

		# Timezone of Ramsgate
		my $tz = $tzdb->get_time_zone({ latitude => 51.34, longitude => 1.42 });

		# if($ENV{'TEST_VERBOSE'}) {
			diag(Data::Dumper->new([$tz])->Dump());
		# }

		my $location = new_ok('Geo::Location::Point' => [ latitude => 51.34, longitude => 1.42 ]);
		$tz = $tzdb->get_time_zone($location);

		# if($ENV{'TEST_VERBOSE'}) {
			diag(Data::Dumper->new([$tz])->Dump());
		# }
	}
}
