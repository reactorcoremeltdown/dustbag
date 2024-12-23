#!/usr/bin/env bash

IFS=$'\n'

USERNAME=`jq -cr '.secrets.grafana_auth.username' /etc/secrets/secrets.json`
PASSWORD=`jq -cr '.secrets.grafana_auth.password' /etc/secrets/secrets.json`

for i in `jq -c '.secrets.grafana_pictures[]' /etc/secrets/secrets.json`; do
	NAME=`echo "${i}" | jq -r .name`
	URL=`echo "${i}" | jq -r .url`
	

	curl -s -u "${USERNAME}:${PASSWORD}" "${URL}" > /opt/apps/graphs/${NAME}.png
done
