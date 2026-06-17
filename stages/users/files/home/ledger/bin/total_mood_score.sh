#!/usr/bin/env bash

TOTAL_SCORE=$(sqlite3 /home/ledger/expenses.db 'select 50 + (select ifnull(sum(score), 0) from moodscore where time > strftime("%s", date("now", "start of day")));')

if [[ "${TOTAL_SCORE}" -gt 60 ]]; then
    curl --request POST \
    --url https://achievements.tiredsysadmin.cc/api/habits/mood/log \
    --header "Authorization: Bearer $(cat /home/ledger/.achieveburger.txt)"
fi

sqlite3 /home/ledger/expenses.db "insert into totalmoodscore(score) values(${TOTAL_SCORE})"
