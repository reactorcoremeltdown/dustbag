#!/usr/bin/env bash

bot_token=`cat /etc/secrets/secrets.json | jq -r .secrets.telegram.bot_token`
chat_id=`cat /etc/secrets/secrets.json | jq -r .secrets.telegram.chat_id`

text=""
tail="\\nHostname: $HOSTNAME\\nCheck name: $NAME\\nDescription: $MESSAGE"
tail_extended="\\nHostname: $HOSTNAME\\nCheck name: $NAME\\nDescription: $MESSAGE\\n\\nLogin: https://http2ssh.tiredsysadmin.cc/go.html?ssh=ssh://rcmd@${HOSTNAME}"

case $STATUS in
  "0")
    text="✅✅✅\\n$tail"
    ;;
  "1")
    text="⚠️⚠️⚠️\\n$tail_extended"
    ;;
  "2")
    text="❌❌❌\\n$tail_extended"
    ;;
esac

#echo -e '{ "actionType": "SendMessage", "actionSettings": {"chatID": '`cat /etc/datasources/pisun-default-chat`', "replyToMessageID": 0, "text": "'"$text"'", "disableWebPagePreview": true }}' | socat stdio unix-connect:/var/run/apps/pisun.sock
curl -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
    -H 'Content-Type: application/json' \
    -d "{ \"chat_id\": \"${chat_id}\", \"text\": \"${text}\" }"

exit 0
