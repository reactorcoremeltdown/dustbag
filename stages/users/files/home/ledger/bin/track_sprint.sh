#!/usr/bin/env bash

IFS=$'\n'

PASSWORD=`cat /home/ledger/.config/kanboard_secret`
REQUEST_ID=`date '+%s'`
INSERTS=""
SPRINT_PROJECT_ID="16"

DATA=`curl -s -u "jsonrpc:${PASSWORD}" -XPOST -H 'Content-Type: application/json' --data "{ \"jsonrpc\": \"2.0\", \"method\": \"searchTasks\", \"id\": ${REQUEST_ID},\"params\": { \"project_id\": ${SPRINT_PROJECT_ID}, \"query\": \"status:open assignee:RCMD\" }}" https://board.rcmd.space/jsonrpc.php`

sleep 1

COLUMNS_REQ_ID=`date +%s`

COLUMNS=`curl -s -u "jsonrpc:${PASSWORD}" -XPOST -H 'Content-Type: application/json' --data "{\"jsonrpc\": \"2.0\", \"method\": \"getColumns\", \"id\": ${COLUMNS_REQ_ID}, \"params\": [ ${SPRINT_PROJECT_ID} ] }" https://board.rcmd.space/jsonrpc.php`

echo "${COLUMNS}"

for col in `echo "${COLUMNS}" | jq -cr '.result[]'`; do
    COLUMN=`echo "${col}" | jq -r '.title'`

    NUM=`echo "${DATA}" | jq -cr ".result[] | select(.column_name==\"${COLUMN}\")" | wc -l`
    INSERTS=${INSERTS}"\ninsert into sprints(id,column) values(${NUM}, \"${COLUMN}\");"
done

INSERTS_RAW=`echo -e "${INSERTS}"`

sqlite3 /home/ledger/expenses.db <<EOF
BEGIN TRANSACTION;
${INSERTS_RAW}
COMMIT;
EOF
