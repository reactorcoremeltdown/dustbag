#!/usr/bin/env bash

bot_token=`cat /etc/datasources/gotify.json | jq -r .token`

text=""
tail="\\nHostname: $HOSTNAME\\nCheck name: $NAME\\nDescription: $MESSAGE"

case $STATUS in
  "0")
    text="✅✅✅\\n$tail"
    ;;
  "1")
    text="⚠️⚠️⚠️\\n$tail"
    ;;
  "2")
    text="❌❌❌\\n$tail"
    ;;
esac

curl -s -XPOST \
    --header "Content-Type: application/json" \
    "https://notifications.rcmd.space/message?token=${bot_token}" \
    --data "{ \"message\": \"${text}\", \"title\": \"WTFD\", \"priority\": 5 }"

exit 0