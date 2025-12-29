#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

if [[ -f ${OPTION} ]]; then
	ok "File ${OPTION} is in place"
else
	fail "File ${OPTION} is not in place!" "$DESCRIPTION" "$ENVIRONMENT"
fi
