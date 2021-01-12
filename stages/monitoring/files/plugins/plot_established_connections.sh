#!/usr/bin/env bash

conns=`netstat -ant | awk '{print $6}' | grep -c ESTABLISHED`

rrdtool update ${1} N:${conns}

echo "GRAPH - see https://status.rcmd.space/builds/operations/"