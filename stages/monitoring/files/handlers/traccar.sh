#!/usr/bin/env bash

bot_token=`cat /etc/secrets/secrets.json | jq -r .secrets.telegram.bot_token`
chat_id="@tiredsysadmin"

text="$MONIT_DESCRIPTION"

case $MONIT_PROGRAM_STATUS in
  "0")
    break
    ;;
  "2")
    curl -X POST "https://api.telegram.org/bot${bot_token}/sendMessage" \
        -H 'Content-Type: application/json' \
        -d "{ \"chat_id\": \"${chat_id}\", \"text\": \"${text}\" }"
    ;;
esac

exit 0
