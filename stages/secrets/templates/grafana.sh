#!/usr/bin/env bash

vault-request-unlock

OAUTH_SECRETS=$(vault-request-key 'oauth_secrets' 'api/grafana')

read -r -d '' INI <<-EOF
[paths]
[server]
root_url = https://graph.rcmd.space
[database]
[datasources]
[remote_cache]
[dataproxy]
[analytics]
[security]
[security.encryption]
[snapshots]
[dashboards]
[users]
[auth]
[auth.anonymous]
enabled = false
org_name = Main Org.
org_role = Viewer
hide_version = true
[auth.github]
[auth.gitlab]
[auth.google]
[auth.grafana_com]
[auth.azuread]
[auth.okta]
[auth.generic_oauth]
name = Gitea
enabled = true
allow_sign_up = true
auto_login = true
skip_org_role_sync = true
scopes = openid email name
${OAUTH_SECRETS}
team_ids =
allowed_organizations =
[auth.basic]
[auth.proxy]
[auth.jwt]
[auth.ldap]
[aws]
[azure]
[rbac]
[smtp]
[emails]
[log]
[log.console]
[log.file]
[log.syslog]
[log.frontend]
[quota]
[unified_alerting]
[unified_alerting.reserved_labels]
[alerting]
[annotations]
[annotations.dashboard]
[annotations.api]
[explore]
[help]
[profile]
[query_history]
[metrics]
[metrics.environment_info]
[metrics.graphite]
[grafana_com]
[tracing.jaeger]
[tracing.opentelemetry]
[tracing.opentelemetry.jaeger]
[tracing.opentelemetry.otlp]
[external_image_storage]
[external_image_storage.s3]
[external_image_storage.webdav]
[external_image_storage.gcs]
[external_image_storage.azure_blob]
[external_image_storage.local]
[rendering]
server_url = http://grafana-renderer.monitoring.svc.cluster.local:8081/render
callback_url = http://grafana.monitoring.svc.cluster.local:3000
[panels]
[plugins]
[live]
[plugin.grafana-image-renderer]
[enterprise]
[feature_toggles]
[date_formats]
# Default system date format used in time range picker and other places where full time is displayed
full_date = DD-MM-YYYY HH:mm:ss

# Used by graph and other places where we only show small intervals
interval_second = HH:mm:ss
interval_minute = HH:mm
interval_hour = DD/MM HH:mm
interval_day = DD/MM
interval_month = MM-YYYY
interval_year = YYYY
[expressions]
[geomap]
EOF

systemctl stop rcmd-api-grafana.service
podman secret rm rcmd-api-grafana || true
echo "${INI}" | podman secret create rcmd-api-grafana -
systemctl start rcmd-api-grafana.service

kubectl get namespace monitoring || kubectl create namespace monitoring
kubectl delete secret --namespace=monitoring grafana || true
echo "${INI}" | kubectl create secret generic --namespace=monitoring grafana --from-file=grafana.ini=/dev/stdin
