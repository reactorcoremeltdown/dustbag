#!/usr/bin/env bash

IFS=$'\n'

for i in `jq -c '.secrets.grafana_pictures[]' /etc/secrets/secrets.json`; do
	NAME=`echo "${i}" | jq -r .name`
	URL=`echo "${i}" | jq -r .url`

	curl -s "${URL}" > /var/storage/wastebox/tiredsysadmin.cc/wiki/pictures/static/${NAME}.png
done
