#!/usr/bin/env bash

BALANCE_DELTA=$(sqlite3 /home/ledger/expenses.db 'select (select balance from balance order by time desc limit 1 offset 1) - (select balance from balance order by time desc limit 1)')

sqlite3 /home/ledger/expenses.db "insert into balance_delta(delta) values(${BALANCE_DELTA})"
