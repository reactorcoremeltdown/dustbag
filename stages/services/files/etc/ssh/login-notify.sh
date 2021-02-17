#!/bin/sh

bot_token=`cat /etc/datasources/gotify.json | jq -r .token`

if [ "$PAM_TYPE" != "close_session" ]; then
    host="`hostname`"
    text="SSH Login: $PAM_USER from $PAM_RHOST on $host"

    case ${PAM_RHOST} in
    "46.88.65.90" | "2a02:2770:3:0:21a:4aff:fecb:2547" )
        echo "${text}" | logger -t sshd-login
        ;;
    *)
        curl -s -XPOST \
            --header "Content-Type: application/json" \
            "https://notifications.rcmd.space/message?token=${bot_token}" \
            --data "{ \"message\": \"${text}\", \"title\": \"SSHD\", \"priority\": 5 }"
        ;;
    esac
fi
