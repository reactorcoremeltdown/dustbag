#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

HASH=$(echo "$1" | md5sum | awk '{print $1}')

OLD_FILE="/tmp/old_file_${HASH}.html"
test -f ${OLD_FILE} || curl -L -s "$1" > ${OLD_FILE}

NEW_FILE="/tmp/new_file_${HASH}.html"
curl -L -s "$1" > ${NEW_FILE}

diff -q ${OLD_FILE} ${NEW_FILE}
ret_code=$?

if [[ $ret_code = 0 ]]; then
    ok "Website $1 unchanged" "$DESCRIPTION"
else
    fail "Website $1 changed!" "$DESCRIPTION"
fi
