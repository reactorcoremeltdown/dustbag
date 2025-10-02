#!/usr/bin/env bash

IFS=$'\n'

for branch in `yq -o=json -I=0 '.debian.reprepro.branches[]' ${1}`; do
    location=$(echo "${branch}" | jq -cr '.location')
    test -d "${location}/repo/conf" || mkdir -p "${location}/repo/conf"
    name=$(echo "${branch}" | jq -cr '.name')
    origin=$(echo "${branch}" | jq -cr '.origin')
    limit=$(echo "${branch}" | jq -cr '.limit')
    components=$(echo "${branch}" | jq -cr '.components')
    description=$(echo "${branch}" | jq -cr '.description')
    signwith=$(echo "${branch}" | jq -cr '.signwith')

    DESTINATION="${location}/repo/conf/distributions"

    test -f ${DESTINATION} && cat /dev/null > ${DESTINATION}

    for distribution in `echo "${branch}" | jq -cr '.distributions[]'`; do
        distro=$(echo "${distribution}" | jq -cr '.name')
        architectures=$(echo "${distribution}" | jq -cr '.architectures')

        echo "Origin: ${origin}" >> ${DESTINATION}
        echo "Label: ${origin}" >> ${DESTINATION}
        echo "Codename: ${distro}" >> ${DESTINATION}
        echo "Architectures: ${architectures}" >> ${DESTINATION}
        echo "Limit: ${limit}" >> ${DESTINATION}
        echo "Components: ${components}" >> ${DESTINATION}
        echo "Description: ${description}" >> ${DESTINATION}
        echo "SignWith: ${signwith}" >> ${DESTINATION}
        echo "" >> ${DESTINATION}
    done

    cd "${location}/repo" && reprepro createsymlinks
done
