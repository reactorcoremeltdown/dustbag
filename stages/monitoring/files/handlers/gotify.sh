#!/usr/bin/env bash


text=""
tail="\\n**Hostname**: $HOSTNAME\\n\\n**Check name**: $NAME\\n\\n**Description**: $MESSAGE"
tail_extended="\\n**Hostname**: $(echo ${HOSTNAME} | sed 's/\./\\\\./g')\\n**Check name**: $NAME\\n**Description**: $(echo "${MESSAGE}" | sed 's/\./\\\\./g;s/!/\\\\!/g')\\n\\n[Login](https://http2ssh.tiredsysadmin.cc/go.html?ssh=ssh://rcmd@$(echo ${HOSTNAME} | sed 's/\./\\\\./g')) | [Downtime 1h](https://api.rcmd.space/internal/protected/downtime?check=${NAME}&downtime=1h) | [Downtime 24h](https://api.rcmd.space/internal/protected/downtime?check=${NAME}&downtime=24h)"

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
    bot_token=` jq -r '.secrets."gotify-ng"[] | select( .name == "critical" ) | .token' /etc/secrets/secrets.json `
    ;;
esac

curl -s -XPOST \
    --header "Content-Type: application/json" \
    "https://notifications.rcmd.space/message?token=${bot_token}" \
    --data "{ \"message\": \"${text}\", \"title\": \"WTFD\", \"priority\": 5, \"extras\": { \"client::display\": { \"contentType\": \"text/markdown\" } } }"

exit 0
