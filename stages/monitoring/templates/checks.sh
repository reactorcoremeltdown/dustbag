#!/usr/bin/env bash

IFS=$'\n'

for check in $(jq -cr '.checks_templates[]' ${1}); do
    source <(echo "${check}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    echo "Check name: ${name}"
    for i in `echo "${notify}"`; do
        echo "Notification parameter: ${i}"
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
notify = ${notify}.sh
EOF
    else
        rm -frv /etc/monitoring/configs/${name}.ini
    fi
done
