#!/usr/bin/env bash

IFS=$'\n'

source /etc/monitoring/plugins/okfail.sh

DATA=`curl -s https://api.alerts.in.ua/v3/stats/duration/today.json | jq -r ".data[] | select(.luid==${1}) | .ex"`

sqlite3 /home/ledger/expenses.db "insert into ua_explosions (location, score) values (${1}, ${DATA})"

CURRENT_SCORE=`sqlite3 /home/ledger/expenses.db "select score from ua_explosions order by time desc limit 1"`
PREVIOUS_SCORE=`sqlite3 /home/ledger/expenses.db "select score from ua_explosions order by time desc limit 1 offset 1"`

LOCATION="No Data"

case $1 in
        "12")
                LOCATION="Zaporizhzhia region"
                ;;
        *)
                LOCATION="Unknown"
                ;;
esac

if [[ ${CURRENT_SCORE} != ${PREVIOUS_SCORE} ]]; then
        fail "The number of explosions at location ${LOCATION} has increased to ${CURRENT_SCORE}! Check reports here: https://alerts.in.ua/en"
else
        ok "There are no new reported explosions at location ${LOCATION}"
fi
