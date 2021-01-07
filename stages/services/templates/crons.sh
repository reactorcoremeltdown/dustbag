#!/usr/bin/env bash

for cron in `ls -1 $1`; do
    cat $cron
done
