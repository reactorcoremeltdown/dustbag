#!/usr/bin/env bash

IFS=$'\n'

for i in `jq -c '.secrets.grafana_pictures[]' /etc/secrets/secrets.json`; do
	NAME=`echo "${i}" | jq -r .name`
	URL=`echo "${i}" | jq -r .url`

	curl -s "${URL}" > /opt/apps/graphs/${NAME}.png
done
