#!/usr/bin/env bash

IFS=$'\n'

for user in `jq -cr '.users[]' ${1}`; do
    USERNAME=`echo "${user}" | jq -r '.name'`
    SHELL=`echo "${user}" | jq -r '.shell'`
    KEYGEN=`echo "${user}" | jq -r '.keygen'`
    GROUPS=`echo "${user}" | jq -r '.groups | join(",")'`
    if ! groups ${USERNAME} > /dev/null; then
        useradd -s ${SHELL} ${USERNAME}
        if [[ ${KEYGEN} = 'true' ]]; then
            su ${USERNAME} -c 'ssh-keygen -b 2048 -t rsa q -N ""'
        fi
    fi
    echo "${GROUPS}"
done
