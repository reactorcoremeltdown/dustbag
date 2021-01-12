#!/usr/bin/env bash

IFS=$'\n'

for check in $(jq -cr '.checks_templates[]' ${1}); do
    source <(echo "${check}" | jq  -cr '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    let "interval = interval * 60"
    echo "Check name: ${name}"
    if [[ ${state} = 'present' ]]; then
        cat << EOF > /etc/monit/conf.d/${name}.cfg
check program ${name} with path /etc/monit/plugins/${plugin}.sh "${argument}" "${description}" "${environment}" "${name}" every ${interval} cycles
	if changed status then exec "/etc/monit/handlers/${notify}.sh"
	if status != 0 then alert
EOF
    else
        rm -frv /etc/monit/conf.d/${name}.cfg
    fi
done
