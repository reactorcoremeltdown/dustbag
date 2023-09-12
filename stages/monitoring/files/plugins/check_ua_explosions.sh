#!/usr/bin/env bash

IFS=$'\n'

source /etc/monitoring/plugins/okfail.sh

DATA=`curl -s https://api.alerts.in.ua/v3/stats/duration/today.json | jq -r ".data[] | select(.luid==${1}) | .ex"`

if [[ "${DATA}" != 'null' ]]; then
        sqlite3 /home/ledger/expenses.db "insert into ua_explosions (location, score) values (${1}, ${DATA})"
else
        sqlite3 /home/ledger/expenses.db "insert into ua_explosions (location, score) values (${1}, 0)"
fi

CURRENT_SCORE=`sqlite3 /home/ledger/expenses.db "select score from ua_explosions where location = ${1} order by time desc limit 1"`
PREVIOUS_SCORE=`sqlite3 /home/ledger/expenses.db "select score from ua_explosions where location = ${1} order by time desc limit 1 offset 1"`

LOCATION="No Data"

case $1 in
        "12")
                LOCATION="Zaporizhzhia region"
                ;;
        *)
                LOCATION="Unknown"
                ;;
esac

if [[ ${CURRENT_SCORE} -gt ${PREVIOUS_SCORE} ]]; then
        fail "The number of explosions at location ${LOCATION} has increased to ${CURRENT_SCORE}!%0ACheck reports here:%0A- https://alerts.in.ua/en%0A- https://t.me/eto_zp%0A- https://t.me/vanek_nikolaev"
else
        ok "There are no new reported explosions at location ${LOCATION}%0AThe current number of cases is ${CURRENT_SCORE}"
fi
