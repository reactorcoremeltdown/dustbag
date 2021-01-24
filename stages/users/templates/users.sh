#!/usr/bin/env bash

IFS=$'\n'

for user in `jq -cr '.users[]' ${1}`; do
    source <(echo "${user}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    HOMEDIR=$(getent passwd ${name} | cut -f 6 -d ':')
    groups ${name} > /dev/null || /sbin/useradd -s ${shell} ${name}
    if [[ ${keygen} = 'true' ]]; then
        test -f ${HOMEDIR}/.ssh/id_rsa || su ${name} -c "ssh-keygen -b 2048 -t rsa -f \"${HOMEDIR}/.ssh/id_rsa\" -q -N \"\""
    fi
    if [[ ${authorized_keys} = 'true' ]]; then
        install -d -m 700 \
            -g ${name} -o ${name} \
            ${HOMEDIR}/.ssh
        install -D -v -m 600 \
            -g ${name} -o ${name} \
            stages/users/files/authorized_keys ${HOMEDIR}/.ssh
    fi
done
