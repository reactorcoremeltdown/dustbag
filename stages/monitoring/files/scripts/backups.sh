#!/usr/bin/env bash

source=${1}
destination=${2}

test -d ${destination} || mkdir ${destination}

GPG_KEY='F70F4BD3AF1D1B95'


source /root/.passphrase
export PASSPHRASE

echo -e "[ $(date) Making a full backup of ${source} ]\n" | logger -t backups 
duplicity full --encrypt-key=${GPG_KEY} ${source} ${destination} 2>&1 | logger -t backups

echo -e "[ $(date) Cleaning up ${source} backups ]\n" | logger -t backups
duplicity remove-all-but-n-full 14 --force ${destination} 2>&1 | logger -t backups
