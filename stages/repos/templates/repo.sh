#!/usr/bin/env bash

IFS=$'\n'
DISTRO=`lsb_release -cs`

for repo in `jq -c '.debian.repositories[]' ${1}`; do
    STATE=`echo ${repo} | jq -r '.state'`
    REPONAME=`echo ${repo} | jq -r '.name'`
    if [[ ${STATE} = 'present' ]]; then
        echo "${repo}" jq -cr '. | "deb \(.url) DISTRO \(.section)"' | sed "s|DISTRO|${DISTRO}|g" > /etc/apt/sources.list.d/${REPONAME}.list
    else
        rm -f /etc/apt/sources.list.d/${REPONAME}.list || true
    fi
done
