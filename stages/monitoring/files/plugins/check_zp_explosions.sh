#!/usr/bin/env bash

IFS=$'\n'

source /etc/monitoring/plugins/okfail.sh

DATA=`jq -cr 'sort_by(.message_id) | reverse | .[0].text' ${1} | grep '‼️' | grep -i 'вибух'`

if [[ "${DATA}" != '' ]]; then
        fail "There is a new explosion registered in Zaporizhzhia!\\n\\nCheck reports here:\\n- https://alerts.in.ua/en\\n- https://t.me/ivan_fedorov_zp\\n- https://t.me/vanek_nikolaev\\n"
else
        ok "There are no new registered explosions in Zaporizhzhia."
fi
