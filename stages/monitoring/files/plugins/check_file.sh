#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

if [[ -f $1 ]]; then
	ok "File $1 is in place. Status: ${WARNING_THRESHOLD}, ${CRITICAL_THRESHOLD}, ${FLOW_OPERATOR}" "$DESCRIPTION" "$ENVIRONMENT"
else
	fail "File $1 is not in place!" "$DESCRIPTION" "$ENVIRONMENT"
fi
