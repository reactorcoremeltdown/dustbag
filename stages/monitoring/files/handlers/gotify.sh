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

curl -s "https://notifications.rcmd.space/message?token=${bot_token}" \
    -F 'title=WTFD' \
    -F "message=${text}" \
    -F "priority=5"

exit 0
