#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

# CONFIG
PROM_URL="http://localhost:9090/api/v1/query"
WARNING_THRESHOLD=${WARNING_THRESHOLD:=1}
CRITICAL_THRESHOLD=${CRITICAL_THRESHOLD:=2}

QUERY="${OPTION}"

if [ -z "$QUERY" ]; then
  echo "UNKNOWN - No PromQL query provided"
  exit 3
fi

# Query Prometheus
RESULT=$(curl -sG --data-urlencode "query=${QUERY}" ${PROM_URL} | jq ".data.result | length")

if [ -z "$RESULT" ]; then
  echo "UNKNOWN - No data returned"
  exit 3
fi

if [ "${RESULT}" -ge "$CRITICAL_THRESHOLD" ]; then
        fail "Query result (${RESULT}) above critical threshold (${CRITICAL_THRESHOLD})!"
elif [ "${RESULT}" -ge "$WARNING_THRESHOLD" ]; then
        warning "Query result (${RESULT}) above warning threshold (${WARNING_THRESHOLD})!"
else
        ok "Query result (${RESULT}) below all thresholds"
fi
