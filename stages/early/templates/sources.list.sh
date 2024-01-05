#!/usr/bin/env bash

IFS=$'\n'
DISTRO=`lsb_release -cs`
DEBIAN_VERSION=`lsb_release -sr`
MIRROR="https://deb.debian.org"

cat <<EOF > /etc/apt/sources.list
deb ${MIRROR}/debian ${DISTRO} main
deb-src ${MIRROR}/debian ${DISTRO} main
deb ${MIRROR}/debian ${DISTRO}-updates main
deb-src ${MIRROR}/debian ${DISTRO}-updates main
deb ${MIRROR}/debian ${DISTRO}-backports main
deb-src ${MIRROR}/debian ${DISTRO}-backports main
EOF

if [[ ${DEBIAN_VERSION} = '11' ]]; then
    cat <<EOF >> /etc/apt/sources.list
deb http://security.debian.org/debian-security ${DISTRO}-security main
deb-src http://security.debian.org/debian-security ${DISTRO}-security main
EOF
fi
