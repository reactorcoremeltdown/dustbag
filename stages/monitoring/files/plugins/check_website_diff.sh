#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

HASH=$(echo "${OPTION}" | md5sum | awk '{print $1}')

OLD_FILE="/tmp/old_file_${HASH}.html"
test -f ${OLD_FILE} || curl -L -s "${OPTION}" > ${OLD_FILE}

NEW_FILE="/tmp/new_file_${HASH}.html"
curl -L -s "${OPTION}" > ${NEW_FILE}

diff -q ${OLD_FILE} ${NEW_FILE}
ret_code=$?

if [[ $ret_code = 0 ]]; then
    ok "Website ${OPTION} unchanged" "$DESCRIPTION"
else
    fail "Website ${OPTION} changed!" "$DESCRIPTION"
fi
