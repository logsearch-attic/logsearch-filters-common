#!/bin/bash -e
basedir=$(cd `dirname $0`/..; pwd)
BUILD_NUMBER=${BUILD_NUMBER:-dev}
TGZ="logsearch-filters-common-${BUILD_NUMBER}.tgz"

echo "====> Packaging..."
echo $(date)
	pushd $basedir/target > /dev/null
	tar cvzf ../$TGZ .
	popd > /dev/null

echo "=====> Done"
echo "Filters in file: $TGZ"