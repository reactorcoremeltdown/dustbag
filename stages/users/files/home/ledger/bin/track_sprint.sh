#!/usr/bin/env bash

IFS=$'\n'

PASSWORD=`cat /home/ledger/.config/kanboard_secret`
REQUEST_ID=`date '+%s'`
INSERTS=""

DATA=`curl -u "jsonrpc:${PASSWORD}" -XPOST -H 'Content-Type: application/json' --data "{ \"jsonrpc\": \"2.0\", \"method\": \"searchTasks\", \"id\": ${REQUEST_ID},\"params\": { \"project_id\": 14, \"query\": \"status:open assignee:RCMD\" }}" https://board.rcmd.space/jsonrpc.php`

for item in `echo "${DATA}" | jq -cr '.result'`; do
    TITLE=`echo "${item}" | jq -r '.title'`
    COLUMN=`echo "${item}" | jq -r '.column_name'`
    INSERTS=${INSERTS}"\ninsert into sprints(title,column) values(\"${TITLE}\", \"${COLUMN}\");"
done

echo "${INSERTS}"

# sqlite3 /home/ledger/expenses.db <<EOF
# BEGIN TRANSACTION;
# ${INSERTS}
# COMMIT;
# EOF
