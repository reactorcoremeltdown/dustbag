#!/usr/bin/env bash

DESTINATION="/home/ledger/Gadgetbridge.db"

test -f ${DESTINATION} && rm -f ${DESTINATION}
cp /tmp/Gadgetbridge.db ${DESTINATION}

STEPS=$(sqlite3 ${DESTINATION} "select sum(STEPS) from HUAWEI_ACTIVITY_SAMPLE where STEPS > 0 and TIMESTAMP > strftime('%s', 'now', 'start of day');")

sqlite3 /home/ledger/expenses.db "insert into health_steps(score) values(${STEPS})"

rm -f /tmp/Gadgetbridge.db
