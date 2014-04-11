#!/bin/bash

#
# This script is responsible for compiling all the filters into static files
# and dumping them into the `target` directory.
#
# In this example, we copy over all the plain configuration files, and then all
# the ERB files get processed.
#

[ -d target ] && rm -fr target
mkdir target/

# plain configs
cp src/*.conf target/

# erb-based configs
LS_HEAP_SIZE="${LS_HEAP_SIZE:=500m}"
JAVA_OPTS="$JAVA_OPTS -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

pushd vendor/logstash > /dev/null
. bin/logstash.lib.sh
popd > /dev/null

basedir=$PWD
setup

for CONFERB in $(find src -name *.conf.erb) ; do
    echo "compiling ${CONFERB}..."
	target_file=`basename $CONFERB`
	target_file=${target_file%.erb}
    $RUBYCMD -e "require 'erb'; puts ERB.new(File.read('$CONFERB')).result(binding)" > target/$target_file
done
