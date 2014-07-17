#!/bin/bash

#
# This script is responsible for running whatever tests are suitable for the
# filters. All tests should be run against the resultant files from the build
# step (the files in target).
#
# This utility asumes we're using rspec for our tests.
#

set -e


echo "===> Building ..."

mkdir -p target/logstash
./bin/build.sh src/logstash/defaults.conf.erb > target/logstash/defaults.conf


echo "===> Testing ..."

./bin/test.sh
