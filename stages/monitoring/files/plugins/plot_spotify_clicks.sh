#!/usr/bin/env bash

clicks=`sqlite3 /var/spool/api/clicks.db "select count(*) from spotify where timestamp >= $(date +%s --date='now - 24 hours');"`

rrdtool update ${1} N:${clicks}

echo "GRAPH - see https://status.rcmd.space/builds/operations/"