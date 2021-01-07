#!/usr/bin/env bash

for cron in `ls -1 $1`; do
    crontab -u $cron stages/services/files/crons/$cron
done
