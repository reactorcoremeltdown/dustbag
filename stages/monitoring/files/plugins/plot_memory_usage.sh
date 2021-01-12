#!/usr/bin/env bash

memory_usage=`free | grep Mem | awk '{print $3/$2 * 100.0}'`

rrdtool update ${1} N:${memory_usage}

echo "GRAPH - see https://status.rcmd.space/builds/operations/"