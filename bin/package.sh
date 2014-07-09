#!/bin/bash -e

# args: [source-dir]
SOURCE_DIR="${SOURCE_DIR:-}"

if [[ "" == "$SOURCE_DIR" ]] ; then
    SOURCE_DIR="$(cd `dirname $0`/.. ; pwd)/target"
fi

BUILD_NUMBER="${BUILD_NUMBER:-dev}"
TGZ="logsearch-filters-common-${BUILD_NUMBER}.tgz"

echo "====> Packaging..."
date

cd $SOURCE_DIR
tar cvzf ../$TGZ .

echo "=====> Done"
echo "Filters in file: $TGZ"
