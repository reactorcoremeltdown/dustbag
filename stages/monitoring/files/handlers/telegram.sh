#!/usr/bin/env bash

bot_token=`cat /etc/datasources/pisun.json | jq -r .token`
chat_id=`cat /etc/datasources/pisun-default-chat`

text=""
tail="\\nHostname: $HOSTNAME\\nCheck name: $MONIT_SERVICE\\nDescription: $MONIT_DESCRIPTION"

case $MONIT_PROGRAM_STATUS in
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

#echo -e '{ "actionType": "SendMessage", "actionSettings": {"chatID": '`cat /etc/datasources/pisun-default-chat`', "replyToMessageID": 0, "text": "'"$text"'", "disableWebPagePreview": true }}' | socat stdio unix-connect:/var/run/apps/pisun.sock
curl -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
    -H 'Content-Type: application/json' \
    -d "{ \"chat_id\": \"${chat_id}\", \"text\": \"${text}\" }"

exit 0
