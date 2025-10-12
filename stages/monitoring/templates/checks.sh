#!/usr/bin/env bash

set -e

IFS=$'\n'

for check in $(yq -o=json -I=0 ".${2}[]" ${1}); do
    # source <(echo "${check}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    name=`echo "${check}" | jq -cr '.name'`
    state=`echo "${check}" | jq -cr '.state'`
    description=`echo "${check}" | jq -cr '.description'`
    plugin=`echo "${check}" | jq -cr '.plugin'`
    argument=`echo "${check}" | jq -cr '.argument'`
    interval=`echo "${check}" | jq -cr '.interval'`
    warningThreshold=`echo "${check}" | jq -cr '.warningThreshold'`
    criticalThreshold=`echo "${check}" | jq -cr '.criticalThreshold'`
    flowOperator=`echo "${check}" | jq -cr '.flowOperator'`
    timeoutSec=`echo "${check}" | jq -cr '.timeoutSec'`

    echo "Check name: ${name}"
    check_hostname=$(echo "${check}" | jq -cr '.hostname')
    for i in `echo "${check}" | jq -cr '.notify[]'`; do
        echo "Notifier added: ${i}"
    done
    if [[ ${state} = 'present' ]]; then
        cat << EOF > /etc/monitoring/configs/${name}.ini
[config]
name = ${name}
description = ${description}
plugin = ${plugin}.sh
argument = ${argument}
interval = ${interval}
timeoutSec = ${timeoutSec}
warningThreshold = ${warningThreshold}
criticalThreshold = ${criticalThreshold}
flowOperator = ${flowOperator}
EOF
        for i in `echo "${check}" | jq -cr '.notify[]'`; do
            echo "notify = ${i}.sh" >> /etc/monitoring/configs/${name}.ini
        done

        SUPPRESORS=`echo "${check}" | jq -cr '.suppressedBy'`

        if [[ ${SUPPRESORS} != 'null' ]]; then
            for i in `echo "${check}" | jq -cr '.suppressedBy[]'`; do
                echo "suppressedBy = ${i}" >> /etc/monitoring/configs/${name}.ini
            done
        fi
        if [[ ${check_hostname} != 'null' ]]; then
            echo "hostname = ${check_hostname}" >> /etc/monitoring/configs/${name}.ini
        fi
    else
        rm -frv /etc/monitoring/configs/${name}.ini
    fi
done
