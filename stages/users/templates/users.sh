#!/usr/bin/env bash

IFS=$'\n'

for user in `jq -cr '.users[]' ${1}`; do
    source <(echo "${user}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    if ! groups ${name} > /dev/null; then
        useradd -s ${shell} ${name}
        if [[ ${keygen} = 'true' ]]; then
            su ${name} -c 'ssh-keygen -b 2048 -t rsa q -N ""'
        fi
        if [[ ${authorized_keys} = 'true' ]]; then
            install -D -v -m 600 \
                -g ${name} -o ${name} \
                stages/users/file/authorized_keys $(echo ~${name})/.ssh/
        fi
    fi
    echo "${groups}"
done
