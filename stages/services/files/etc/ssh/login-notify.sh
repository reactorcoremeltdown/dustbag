#!/bin/sh

bot_token=`jq -r '.secrets.gotify.token' /etc/secrets/secrets.json`

env | grep PAM >> /tmp/gogo.env

# if [ "$PAM_TYPE" != "close_session" ]; then
#     host="`hostname`"
#     text="SSH Login: $PAM_USER from $PAM_RHOST on $host"
# 
#     case ${PAM_RHOST} in
#     "157.90.254.55" | "2a01:4f8:c010:730d::1" | "46.88.65.90" )
#         echo "${text}" | logger -t "sshd-login"
#         ;;
#     *)
#         curl -s -XPOST \
#             --header "Content-Type: application/json" \
#             "https://notifications.rcmd.space/message?token=${bot_token}" \
#             --data "{ \"message\": \"${text}\", \"title\": \"SSHD\", \"priority\": 5 }"
#         ;;
#     esac
# fi
