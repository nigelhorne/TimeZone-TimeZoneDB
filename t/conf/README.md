# Test-Corpus Configuration Files

This directory contains configuration and static corpus files for fuzzing and testing Perl modules using the [Test-Corpus](https://github.com/nigelhorne/Test-Corpus) generator.

## File Structure

- `get_time_zone.conf` – Configuration for `TimeZone::TimeZoneDB->get_time_zone`, including input/output definitions, edge cases, and fuzzing parameters.
- `get_time_zone.yml` – Static corpus for `get_time_zone`, providing example valid and invalid inputs.

## Running the Fuzz Harness

From the root of the repository:

```bash
perl fuzz_harness_generator.pl t/conf/get_time_zone.conf
