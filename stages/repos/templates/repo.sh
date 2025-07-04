#!/usr/bin/env bash

IFS=$'\n'
DISTRO=`lsb_release -cs`
DEBIAN_VERSION=`lsb_release -sr`


for repo in `yq -o=json -I=0 '.debian.repositories[]' ${1}`; do
    source <(echo "${repo}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    if [[ ${state} = 'present' ]]; then
        test -z ${distro} && distro=${DISTRO}
        if [[ ${DEBIAN_VERSION} -lt 11 ]]; then
            KEYRING="/etc/apt/trusted.gpg.d/${name}.gpg"
            test -z ${key} || test -f ${KEYRING} || apt-key --keyring ${KEYRING} adv --fetch-keys --no-tty ${key}
            echo "${repo}" | jq -cr '. | "deb \(.url) DISTRO \(.section)"' | sed "s|DISTRO|${distro}|g" > /etc/apt/sources.list.d/${name}.list
        else
            KEYRING="/usr/share/keyrings/${name}.gpg"
            test -z ${key} || test -f ${KEYRING} || curl -s ${key} | gpg --dearmor > ${KEYRING}
            echo "${repo}" | jq -cr '. | "deb [signed-by=KEYRING] \(.url) DISTRO \(.section)"' | sed "s|DISTRO|${distro}|g;s|KEYRING|${KEYRING}|" > /etc/apt/sources.list.d/${name}.list
        fi
    else
        rm -fv /etc/apt/sources.list.d/${name}.list || true
    fi
done
