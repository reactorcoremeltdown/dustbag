ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

gitea_directory:
	install -d -m 770 --owner git --group git /etc/gitea

gitea_config: /etc/secrets/secrets.json
	test -d /home/git/.config || mkdir -p /home/git/.config && chown git:git /home/git/.config
	bash $(ROOT_DIR)/templates/gitea/config.sh
	install -D -m 644 -v $(ROOT_DIR)/files/etc/systemd/system/gitea.service /etc/systemd/system
	rbw get --folder 'gitea/server' DRONE_API_KEY > /home/git/.config/drone_api_key
	chmod 400 /home/git/.config/drone_api_key && chown git:git /home/git/.config/drone_api_key
	install -D -m 755 -v $(ROOT_DIR)/files/usr/local/bin/gitea-common-hook /usr/local/bin	
	systemctl enable gitea.service
	systemctl daemon-reload

gitea: gitea_directory gitea_config
	@echo "$(ccgreen)Setting up gitea completed$(ccend)"

registry:
	install -D -m 644 $(ROOT_DIR)/files/etc/containers/containers.conf /etc/containers
	install -D -m 644 $(ROOT_DIR)/files/etc/docker/registry/config.yml /etc/docker/registry
	systemctl restart docker-registry
	@echo "$(ccgreen)Setting up docker registry completed$(ccend)"

network_hacks:
	install -D -m 644 $(ROOT_DIR)/files/etc/systemd/system/nat-flush.service /etc/systemd/system
	install -D -m 644 $(ROOT_DIR)/files/etc/systemd/system/containers.target /etc/systemd/system
	systemctl daemon-reload
	systemctl enable nat-flush.service
	systemctl enable containers.target
	@echo "$(ccgreen)Setting up network hacks completed$(ccend)"

podman: network_hacks
	install -D -m 644 $(ROOT_DIR)/files/etc/containers/registries.conf /etc/containers
	bash $(ROOT_DIR)/templates/podman/podman-login.service.sh
	systemctl enable podman-login.service
	@echo "$(ccgreen)Setting up prometheus completed$(ccend)"

fdroid:
	test -d /var/lib/fdroid || mkdir /var/lib/fdroid
	bash $(ROOT_DIR)/templates/nginx/sites/fdroid.sh
	nginx -t
	systemctl reload nginx.service
	@echo "$(ccgreen)Setting up fdroid completed$(ccend)"

drone_server:
	mkdir -p /etc/drone || true
	bash $(ROOT_DIR)/templates/drone/server.cfg.sh
	test -f /etc/drone/server.cfg && md5sum /etc/drone/server.cfg > /etc/drone/checksum.txt
	mkdir -p /var/lib/drone || true
	install -D -m 644 $(ROOT_DIR)/files/etc/systemd/system/drone-server.service /etc/systemd/system
	systemctl enable drone-server.service
	@echo "$(ccgreen)Installed drone server$(ccend)"

drone_runner_amd64:
	install -D -v -m 755 \
		$(ROOT_DIR)/files/usr/local/bin/telegram.run \
		/usr/local/bin
	mkdir -p /home/git/.drone-runner-exec || true
	chown git:git /home/git/.drone-runner-exec
	bash $(ROOT_DIR)/templates/drone/runner.cfg.sh
	install -D -m 755 $(ROOT_DIR)/files/usr/local/bin/drone-runner-amd64 /usr/local/bin
	install -D -m 644 $(ROOT_DIR)/files/etc/systemd/system/drone-runner-amd64.service /etc/systemd/system
	systemctl enable drone-runner-amd64.service
	echo "sleep 2 && systemctl start drone-runner-amd64.service" | at now
	@echo "$(ccgreen)Installed drone runner$(ccend)"

drone_runner_arm:
	install -D -v -m 755 \
		$(ROOT_DIR)/files/usr/local/bin/telegram.run \
		/usr/local/bin
	mkdir -p /home/git/.drone-runner-exec || true
	chown git:git /home/git/.drone-runner-exec
	bash $(ROOT_DIR)/templates/drone/runner.cfg.sh
	install -D -m 755 $(ROOT_DIR)/files/usr/local/bin/drone-runner-arm /usr/local/bin
	install -D -m 644 $(ROOT_DIR)/files/etc/systemd/system/drone-runner-arm.service /etc/systemd/system
	systemctl enable drone-runner-arm.service
	echo "sleep 2 && systemctl start drone-runner-arm.service" | at now
	@echo "$(ccgreen)Installed drone runner$(ccend)"
