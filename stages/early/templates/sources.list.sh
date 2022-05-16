#!/usr/bin/env bash

IFS=$'\n'
DISTRO=`lsb_release -cs`
DEBIAN_VERSION=`lsb_release -sr`

cat <<EOF > /etc/apt/sources.list
deb http://debian.mirror.iphh.net/debian ${DISTRO} main
deb-src http://debian.mirror.iphh.net/debian ${DISTRO} main
deb http://debian.mirror.iphh.net/debian ${DISTRO}-updates main
deb-src http://debian.mirror.iphh.net/debian ${DISTRO}-updates main
deb http://debian.mirror.iphh.net/debian ${DISTRO}-backports main
deb-src http://debian.mirror.iphh.net/debian ${DISTRO}-backports main
EOF

if [[ ${DEBIAN_VERSION} = '11' ]]; then
    cat <<EOF >> /etc/apt/sources.list
deb http://security.debian.org/debian-security ${DISTRO}-security main
deb-src http://security.debian.org/debian-security ${DISTRO}-security main
EOF
fi
