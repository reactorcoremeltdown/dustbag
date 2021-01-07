#!/usr/bin/env bash

for cron in `ls -1 $1`; do
    echo $cron
done
