#!/bin/bash

#
# This script takes care of installing all the dependencies needed for
# developing and testing the logstash filters.
#
# You might need to install additional gems if you're doing fancy filters. In
# this case, we're simply ensuring logstash source is available.
#

set -e

if [ '' == "$1" ] ; then
  # assume they want the latest version
  LOGSTASH_VERSION=1.4.0
else
  LOGSTASH_VERSION=$1
fi

if [ ! -e vendor/logstash ] ; then
  mkdir vendor/logstash
  wget -qO- "https://github.com/elasticsearch/logstash/archive/v$LOGSTASH_VERSION.tar.gz" | tar -xzf- -C vendor/logstash --strip-components 1
fi

cd vendor/logstash

make vendor-jruby
bin/logstash deps

if [ -e bin/plugin ] ; then
  echo "Adding community plugins ... (takes a few minutes)"
  bin/plugin install contrib
fi
