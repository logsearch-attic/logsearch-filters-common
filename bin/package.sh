#!/bin/bash -e
BASE_DIR=$(cd `dirname $0`/.. ; pwd)

# args: [source-dir]
SOURCE_DIR="${SOURCE_DIR:-}"

if [[ "" == "$SOURCE_DIR" ]] ; then
    SOURCE_DIR="$BASE_DIR/target"
fi

BUILD_NUMBER="${BUILD_NUMBER:-dev}"
GIT_HASH=$(cd $BASE_DIR; git rev-list -1 HEAD . | cut -c-7)
TGZ="logsearch-filters-common-${BUILD_NUMBER}.${GIT_HASH}.tgz"

echo "====> Packaging..."
date

cd $SOURCE_DIR
tar cvzf ../$TGZ .

echo "=====> Done"
echo "Filters in file: $TGZ"
