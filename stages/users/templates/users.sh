#!/usr/bin/env bash

IFS=$'\n'

for user in `jq -cr '.users[]' ${1}`; do
    source <(echo "${user}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    if ! groups ${name} > /dev/null; then
        /sbin/useradd -s ${shell} ${name}
        if [[ ${keygen} = 'true' ]]; then
            su ${name} -c 'ssh-keygen -b 2048 -t rsa q -N ""'
        fi
        if [[ ${authorized_keys} = 'true' ]]; then
            HOMEDIR=$(getent passwd ${name} | cut -f 6 -d ':')
            install -d -m 700 \
                -g ${name} -o ${name} \
                ${HOMEDIR}/.ssh
            install -D -v -m 600 \
                -g ${name} -o ${name} \
                stages/users/files/authorized_keys ${HOMEDIR}/.ssh
        fi
    fi
    #echo "${groups}"
done
