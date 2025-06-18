#!/usr/bin/env bash

TOTAL_SCORE=$(sqlite3 /home/ledger/expenses.db 'select count(*) from alert_fatigue where time > strftime("%s", date("now", "start of day"));')

sqlite3 /home/ledger/expenses.db "insert into alert_fatigue_total(score) values(${TOTAL_SCORE})"
