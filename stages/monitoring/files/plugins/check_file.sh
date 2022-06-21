#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

if [[ -f $1 ]]; then
	ok "File $1 is in place"
else
	fail "File $1 is not in place!" "$DESCRIPTION" "$ENVIRONMENT"
fi
