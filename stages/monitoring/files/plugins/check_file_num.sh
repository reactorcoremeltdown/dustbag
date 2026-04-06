#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

# CONFIG
WARNING_THRESHOLD=${WARNING_THRESHOLD:=3}
CRITICAL_THRESHOLD=${CRITICAL_THRESHOLD:=5}

QUERY="${OPTION}"

if [ -z "$QUERY" ]; then
  echo "UNKNOWN - No directory specified"
  exit 3
fi

# Find files in a directory
RESULT=$(find "${QUERY}" -type f | wc -l)

if [ -z "$RESULT" ]; then
  echo "UNKNOWN - No data returned"
  exit 3
fi

if [ "${RESULT}" -ge "$CRITICAL_THRESHOLD" ]; then
        fail "Directory contains files (${RESULT}) above critical threshold (${CRITICAL_THRESHOLD})!"
elif [ "${RESULT}" -ge "$WARNING_THRESHOLD" ]; then
        warning "Directory contains files (${RESULT}) above warning threshold (${WARNING_THRESHOLD})!"
else
        ok "Directory files number (${RESULT}) below all thresholds"
fi
