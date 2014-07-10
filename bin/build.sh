#!/bin/bash

#
# This accepts any number of files which are then parsed and dumped back out to
# STDOUT as a final, useable logstash filters configuration file.
#

set -e

# args: input-file...

LS_HEAP_SIZE="${LS_HEAP_SIZE:=500m}"
JAVA_OPTS="${JAVA_OPTS:-} -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

. vendor/logstash/bin/logstash.lib.sh

basedir=$PWD
setup

for SOURCE_FILE in $@ ; do
    $RUBYCMD -e "require 'erb'; puts ERB.new(File.read('$SOURCE_FILE')).result(binding)"
done
