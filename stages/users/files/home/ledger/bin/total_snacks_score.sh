#!/usr/bin/env bash

TOTAL_SCORE=$(select count(*) from expenses where category = "expenses:food:snacks" and time > strftime("%s", date("now", "start of day"));')

sqlite3 /home/ledger/expenses.db "insert into snacks_total(score) values(${TOTAL_SCORE})"
