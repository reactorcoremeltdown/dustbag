#!/usr/bin/env bash

for check in $(jq -cr '.checks_templates' ${1}); do
    source <(echo "${check}" | jq '. | to_entries[] | [.key,(.value|@sh)] | join("=")')
    let "interval = interval * 60"
    echo ${name}
    cat << EOF > /etc/monit/conf.d/${name}.conf
check program ${name} with path /etc/monit/plugins/${plugin}.sh "${argument }" "${description}" "${environment}" "${name}" every ${interval} cycles
	if changed status then exec "/etc/monit/handlers/${notify}.sh"
	if status != 0 then alert
EOF
done
