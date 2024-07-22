#!/usr/bin/env bash

STORAGE_PATH="/media/external"

USED=`df --output=pcent ${STORAGE_PATH} | tail -n 1 | sed 's| ||g' | cut -f 1 -d %`

if [[ ${USED} -lt 15 ]]; then
    rm -fr ${STORAGE_PATH}/*mkv
fi
