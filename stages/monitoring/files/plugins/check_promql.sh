#!/usr/bin/env bash

source /etc/monitoring/plugins/okfail.sh

# CONFIG
PROM_URL="http://localhost:9090/api/v1/query"
WARNING_THRESHOLD=${WARNING_THRESHOLD:=1}
CRITICAL_THRESHOLD=${CRITICAL_THRESHOLD:=2}

QUERY="$1"

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
        fail "Query result above critical threshold!"
elif [ "${RESULT}" -ge "$WARNING_THRESHOLD" ]; then
        warning "Query result above warning threshold!"
else
        ok "Query result below all thresholds"
fi
