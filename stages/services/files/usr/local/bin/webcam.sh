#!/usr/bin/env bash

TOKEN=$(jq -cr '.secrets.telegram.bot_token' /etc/secrets/secrets.json)
CHAT=$(jq -cr '.secrets.telegram.chat_id' /etc/secrets/secrets.json)

curl -s -X POST "https://api.telegram.org/bot${TOKEN}/sendPhoto" -F "chat_id=${CHAT}" -F "photo=@${1}"

rm -fr ${1}
