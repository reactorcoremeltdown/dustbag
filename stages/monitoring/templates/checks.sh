#!/usr/bin/env bash

IFS=$'\n'

for check in $(jq -cr ".${2}[]" ${1}); do
    source <(echo "${check}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
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
warningThreshold = ${warningThreshold}
criticalThreshold = ${criticalThreshold}
flowOperator = ${flowOperator}
EOF
        for i in `echo "${check}" | jq -cr '.notify[]'`; do
            echo "notify = ${i}.sh" >> /etc/monitoring/configs/${name}.ini
        done
        for i in `echo "${check}" | jq -cr '.suppressedBy[]'`; do
            echo "suppressedBy = ${i}" >> /etc/monitoring/configs/${name}.ini
        done
        if [[ ${check_hostname} != 'null' ]]; then
            echo "hostname = ${check_hostname}" >> /etc/monitoring/configs/${name}.ini
        fi
    else
        rm -frv /etc/monitoring/configs/${name}.ini
    fi
done
