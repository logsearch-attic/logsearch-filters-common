#!/bin/bash

#
# This script simply runs through a list of commands, exiting if one errors.
#

set -e

for TASK in $@ ; do
    echo "--> $TASK"
    $TASK
done
