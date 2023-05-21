#!/usr/bin/env bash

PASSWORD=`cat /home/ledger/.config/kanboard_secret`
REQUEST_ID=`date '+%s'`

DATA=`curl -u "jsonrpc:${PASSWORD}" -XPOST -H 'Content-Type: application/json' --data "{ \"jsonrpc\": \"2.0\", \"method\": \"searchTasks\", \"id\": ${REQUEST_ID},\"params\": { \"project_id\": 14, \"query\": \"status:open assignee:RCMD\" }}" https://board.rcmd.space/jsonrpc.php`

echo "$DATA"
