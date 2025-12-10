#!/usr/bin/env bash

IFS=$'\n'
DISTRO_SLUG=`lsb_release -cs`
DEBIAN_VERSION=`lsb_release -sr`
MAKECMDGOALS="${2}"

echo "Setting up debian packages on ${MAKECMDGOALS}"


for repo in `yq -o=json -I=0 '.debian.repositories[]' ${1}`; do
    unset distro
    source <(echo "${repo}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    if echo "${install_on}" | grep -oq ${MAKECMDGOALS}; then
        if echo "${state}" | grep -oq "present"; then
            echo "Current distro is ${distro}"
            test -z ${distro} && distro=${DISTRO_SLUG}
            if [[ ${DEBIAN_VERSION} -lt 11 ]]; then
                KEYRING="/etc/apt/trusted.gpg.d/${name}.gpg"
                test -z ${key} || test -f ${KEYRING} || apt-key --keyring ${KEYRING} adv --fetch-keys --no-tty ${key}
                echo "${repo}" | jq -cr '. | "deb \(.url) DISTRO \(.section)"' | sed "s|DISTRO|${distro}|g" > /etc/apt/sources.list.d/${name}.list
            else
                KEYRING="/usr/share/keyrings/${name}.gpg"
                test -z ${key} || test -f ${KEYRING} || curl -s -L ${key} | gpg --dearmor > ${KEYRING}
                echo "${repo}" | jq -cr '. | "deb [signed-by=KEYRING] \(.url) DISTRO \(.section)"' | sed "s|DISTRO|${distro}|g;s|KEYRING|${KEYRING}|" > /etc/apt/sources.list.d/${name}.list
            fi
        else
            rm -fv /etc/apt/sources.list.d/${name}.list || true
        fi
    else
        rm -fv /etc/apt/sources.list.d/${name}.list || true
    fi
done
