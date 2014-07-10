#!/bin/bash

#
# This script is responsible for running whatever tests are suitable for the
# filters. All tests should be run against the resultant files from the build
# step (the files in target).
#
# This utility asumes we're using rspec for our tests.
#

set -e

export JAVA_OPTS="$JAVA_OPTS -XX:+TieredCompilation -XX:TieredStopAtLevel=1"


echo "===> Building ..."

mkdir -p target
./bin/build.sh src/defaults.conf.erb > target/defaults.conf


echo "===> Testing ..."

./vendor/logstash/bin/logstash rspec $(find test -name *spec.rb)
