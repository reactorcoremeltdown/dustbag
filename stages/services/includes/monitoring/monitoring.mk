ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

deviceping:
	test -f /root/.deviceping || (vault-request-unlock && vault-request-key users api/main | yq -r ".[] | select(.username == \"$(DEVICEPING_ID)\") | .key" > /root/.deviceping)
	chmod 400 /root/.deviceping
	install -D -m 755 stages/services/includes/monitoring/files/usr/local/bin/deviceping /usr/local/bin
	@echo "$(ccgreen)Setting up deviceping completed$(ccend)"

deviceping_receiver:
	install -D -m 755 stages/services/includes/monitoring/files/usr/local/bin/deviceping-receiver /usr/local/bin
	test -d /var/spool/api/deviceping || mkdir -p /var/spool/api/deviceping
	@echo "$(ccgreen)Setting up deviceping completed$(ccend)"

exported_graphs:
	test -d /opt/apps/graphs || mkdir -p /opt/apps/graphs
	install -D -m 755 stages/services/includes/monitoring/files/usr/local/bin/grafana_pictures.sh /usr/local/bin
	@echo "$(ccgreen)Setting up graphs completed$(ccend)"

gotify:
	test -d /var/lib/gotify || mkdir -p /var/lib/gotify
	install -D -m 644 stages/services/includes/monitoring/files/etc/systemd/system/gotify.service /etc/systemd/system
	systemctl enable gotify.service
	systemctl restart gotify.service
	bash stages/services/includes/monitoring/templates/nginx/sites/gotify.sh
	nginx -t && systemctl reload nginx.service
