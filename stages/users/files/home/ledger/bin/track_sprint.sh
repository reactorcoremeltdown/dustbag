#!/usr/bin/env bash

IFS=$'\n'

PASSWORD=`cat /home/ledger/.config/kanboard_secret`
REQUEST_ID=`date '+%s'`
INSERTS=""

DATA=`curl -s -u "jsonrpc:${PASSWORD}" -XPOST -H 'Content-Type: application/json' --data "{ \"jsonrpc\": \"2.0\", \"method\": \"searchTasks\", \"id\": ${REQUEST_ID},\"params\": { \"project_id\": 14, \"query\": \"status:open assignee:RCMD\" }}" https://board.rcmd.space/jsonrpc.php`

for item in `echo "${DATA}" | jq -cr '.result[]'`; do
    TASK_ID=`echo "${item}" | jq -r '.id'`
    COLUMN=`echo "${item}" | jq -r '.column_name'`
    INSERTS=${INSERTS}"\ninsert into sprints(id,column) values(${TASK_ID}, \"${COLUMN}\");"
done

INSERTS_RAW=`echo -e "${INSERTS}"`

sqlite3 /home/ledger/expenses.db <<EOF
BEGIN TRANSACTION;
${INSERTS_RAW}
COMMIT;
EOF
