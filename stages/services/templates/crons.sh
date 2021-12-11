#!/usr/bin/env bash

for cron in `ls -1 $1`; do
    crontab -u $cron $1/$cron
done
