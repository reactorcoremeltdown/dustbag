#!/usr/bin/env bash

IFS=$'\n'
DISTRO=`lsb_release -cs`

for repo in `jq -c '.debian.repositories[]' ${1}`; do
    source <(echo "${repo}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    KEYRING="/etc/apt/trusted.gpg.d/${name}.gpg"
    if [[ ${state} = 'present' ]]; then
        test -z ${distro} && distro=${DISTRO}
        test -f ${KEYRING} || apt-key --keyring ${KEYRING} adv --fetch-keys --no-tty ${key}
        echo "${repo}" | jq -cr '. | "deb \(.url) DISTRO \(.section)"' | sed "s|DISTRO|${distro}|g" > /etc/apt/sources.list.d/${name}.list
    else
        rm -fv /etc/apt/sources.list.d/${name}.list ${KEYRING} || true
    fi
done
