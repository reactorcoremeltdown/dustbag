#!/usr/bin/env bash

STORAGE_PATH="/path/to/storage"

USED=`df --output=pcent ${STORAGE_PATH}`

if [[ ${USED} -lt 5 ]]; then
    rm -fr ${STORAGE_PATH}/*mkv
fi
