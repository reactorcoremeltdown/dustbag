#!/usr/bin/env bash

swap_usage=`free -t | awk 'NR == 3 {print $3/$2*100}'`

rrdtool update ${1} N:${swap_usage}

echo "GRAPH - see https://status.rcmd.space/builds/operations/"