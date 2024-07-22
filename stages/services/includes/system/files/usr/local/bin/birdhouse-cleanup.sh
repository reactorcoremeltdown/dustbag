#!/usr/bin/env bash

STORAGE_PATH="/media/external"

USED=`df --output=pcent ${STORAGE_PATH}`

if [[ ${USED} -lt 5 ]]; then
    rm -fr ${STORAGE_PATH}/*mkv
fi
