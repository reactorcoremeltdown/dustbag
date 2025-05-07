#!/usr/bin/env bash

bot_token=`cat /etc/secrets/secrets.json | jq -r .secrets.telegram.bot_token`
chat_id=`cat /etc/secrets/secrets.json | jq -r .secrets.telegram.chat_id`

text=""
tail="\\n**Hostname**: $(echo ${HOSTNAME} | sed 's/\./\\\\./g')\\n**Check name**: $NAME\\n**Description**: $(echo "${MESSAGE}" | sed 's/\./\\\\./g;s/!/\\\\!/g')"
tail_extended="\\n**Hostname**: $(echo ${HOSTNAME} | sed 's/\./\\\\./g')\\n**Check name**: $NAME\\n**Description**: $(echo "${MESSAGE}" | sed 's/\./\\\\./g;s/!/\\\\!/g')\\n\\n**Login**: [$(echo ${HOSTNAME} | sed 's/\./\\\\./g')](https://http2ssh.tiredsysadmin.cc/go.html?ssh=ssh://rcmd@$(echo ${HOSTNAME} | sed 's/\./\\\\./g'))"

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
    -d "{ \"chat_id\": \"${chat_id}\", \"text\": \"${text}\", \"parse_mode\": \"MarkdownV2\" }" 2>&1 >> /tmp/telegram.log

exit 0
