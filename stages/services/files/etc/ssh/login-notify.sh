#!/bin/sh

bot_token=`cat /etc/datasources/gotify.json | jq -r .token`

if [ "$PAM_TYPE" != "close_session" ]; then
    host="`hostname`"
    text="SSH Login: $PAM_USER from $PAM_RHOST on $host"

    curl -s -XPOST \
        --header "Content-Type: application/json" \
        "https://notifications.rcmd.space/message?token=${bot_token}" \
        --data "{ \"message\": \"${text}\", \"title\": \"SSHD\", \"priority\": 5 }"
fi
