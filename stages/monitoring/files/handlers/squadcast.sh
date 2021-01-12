#!/usr/bin/env bash

source /etc/datasources/squadcast.env

EVENT_FILE="/var/lib/monit/events/${MONIT_SERVICE}"

case $MONIT_PROGRAM_STATUS in
  "0")
    EVENT_ID=$(cat ${EVENT_FILE})
    curl -X POST "https://api.squadcast.com/v2/incidents/api/${SQUADCAST_TOKEN}" \
        -H 'Content-Type: application/json' \
        -d "{ \"status\": \"resolved\", \"event_id\": \"${EVENT_ID}\" }"
    echo "" > ${EVENT_FILE}
    ;;
  "1"|"2")
    uuidgen > $EVENT_FILE
    EVENT_ID=$(cat ${EVENT_FILE})
    curl -X POST "https://api.squadcast.com/v2/incidents/api/${SQUADCAST_TOKEN}" \
        -H 'Content-Type: application/json' \
        -d "{ \"message\": \"${MONIT_SERVICE}\", \"description\": \"${MONIT_DESCRIPTION}\", \"status\": \"trigger\", \"event_id\": \"${EVENT_ID}\" }"
    ;;
esac

exit 0