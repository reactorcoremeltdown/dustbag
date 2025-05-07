#!/usr/bin/env bash


text=""
tail="\\n**Hostname**: $HOSTNAME\\n\\n**Check name**: $NAME\\n\\n**Description**: $MESSAGE"
tail_extended="\\n**Hostname**: $HOSTNAME\\n\\n**Check name**: $NAME\\n\\n**Description**: $MESSAGE\\n\\n**Login**: [${HOSTNAME}](https://http2ssh.tiredsysadmin.cc/go.html?ssh=ssh://rcmd@${HOSTNAME})"

case $STATUS in
  "0")
    text="✅✅✅\\n$tail"
    bot_token=` jq -r '.secrets."gotify-ng"[] | select( .name == "ok" ) | .token' /etc/secrets/secrets.json `
    ;;
  "1")
    text="⚠️⚠️⚠️\\n$tail_extended"
    bot_token=` jq -r '.secrets."gotify-ng"[] | select( .name == "warning" ) | .token' /etc/secrets/secrets.json `
    ;;
  "2")
    text="❌❌❌\\n$tail_extended"
    bot_token=` jq -r '.secrets."gotify-ng"[] | select( .name == "disaster" ) | .token' /etc/secrets/secrets.json `
    ;;
esac

curl -s -XPOST \
    --header "Content-Type: application/json" \
    "https://notifications.rcmd.space/message?token=${bot_token}" \
    --data "{ \"message\": \"${text}\", \"title\": \"WTFD\", \"priority\": 5, \"extras\": { \"client::display\": { \"contentType\": \"text/markdown\" } } }"

exit 0
