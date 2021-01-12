#!/usr/bin/env bash

loadavg=`cat /proc/loadavg | awk '{print $2}'`

rrdtool update ${1} N:${loadavg}

echo "GRAPH - see https://status.rcmd.space/builds/operations/"