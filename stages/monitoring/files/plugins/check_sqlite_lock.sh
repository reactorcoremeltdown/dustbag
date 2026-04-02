#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

sqlite3 "${OPTION}" "BEGIN EXCLUSIVE; COMMIT;"
ret_code=$?

if [[ $ret_code = 0 ]]; then
    ok "SQLite DB ${OPTION} is unlocked" "$DESCRIPTION" "$ENVIRONMENT"
else
    fail "SQLite DB ${OPTION} is locked, check usage with fuser" "$DESCRIPTION" "$ENVIRONMENT"
fi
