#!/bin/bash

#
# This script is responsible for compiling all the filters into static files
# and dumping them into the `target` directory.
#
# In this example, we copy over all the plain configuration files, and then all
# the ERB files get processed.
#

set -e

# args: [source-dir [target-dir]]
SOURCE_DIR="${1:-src}"
TARGET_DIR="${2:-target}"

rm -fr $TARGET_DIR/*
mkdir -p $TARGET_DIR/


#
# plain configs
#

for SOURCE_FILE in $(find "$SOURCE_DIR" -name *.conf) ; do
    TARGET_NAME=`basename "$SOURCE_FILE"`

    echo -n "$TARGET_NAME..."

    cp "$SOURCE_FILE" "$TARGET_DIR/$TARGET_NAME"

    echo "done"
done


#
# erb-based configs
#

LS_HEAP_SIZE="${LS_HEAP_SIZE:=500m}"
JAVA_OPTS="${JAVA_OPTS:-} -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

pushd vendor/logstash > /dev/null
. bin/logstash.lib.sh
popd > /dev/null

basedir=$PWD
setup

for SOURCE_FILE in $(find "$SOURCE_DIR" -name *.conf.erb) ; do
    TARGET_NAME=`basename "$SOURCE_FILE"`

    echo -n "${TARGET_NAME}..."

	TARGET_NAME=${TARGET_NAME%.erb}

    $RUBYCMD -e "require 'erb'; puts ERB.new(File.read('$SOURCE_FILE')).result(binding)" > $TARGET_DIR/$TARGET_NAME

    echo "done"
done
