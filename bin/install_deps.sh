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

# The logsearch-workspace already contains logstash, so use that
if [ -e /usr/local/logstash-$LOGSTASH_VERSION ] ; then
  echo "Detected that running in Logsearch Workspace.  Linking to logstash at /usr/local/logstash-$LOGSTASH_VERSION" 
  if [ ! -e vendor/logstash ] ; then
     ln -s /usr/local/logstash-$LOGSTASH_VERSION vendor/logstash
  fi
  exit
fi

if [ ! -e vendor/logstash ] ; then
  mkdir vendor/logstash
  curl -L "https://github.com/elasticsearch/logstash/archive/v$LOGSTASH_VERSION.tar.gz" | tar -xzf- -C vendor/logstash --strip-components 1
fi

if [ "$OS" == "Windows_NT" ] ; then
	echo "Setting up extra Windows dependencies"
	if ! which make ; then
	  pushd $TMP
	  curl -L -O http://gnuwin32.sourceforge.net/downlinks/make-bin-zip.php
	  unzip make-bin-zip.php -d / bin/make.exe
	  curl -L -O http://gnuwin32.sourceforge.net/downlinks/make-dep-zip.php
	  unzip make-dep-zip.php -d / bin/libiconv2.dll bin/libintl3.dll
	  
	  rm -f make-bin-zip.php 
	  rm -f make-dep-zip.php
	  popd
	fi
fi 

cd vendor/logstash

make vendor-jruby
bin/logstash deps

if [ -e bin/plugin ] ; then
  echo "Adding community plugins ... (takes a few minutes)"
  bin/plugin install contrib
fi
