services: users packages sshd crons laminar gitea nginx davfs2 podsync
	@echo "$(ccgreen)Setting up services completed$(ccend)"

sshd_config:
	install -D -v -m 644 \
		stages/services/files/etc/ssh/sshd_config \
		/etc/ssh
	install -D -v -m 755 \
		stages/services/files/etc/ssh/login-notify.sh \
		/etc/ssh
	install -D -v -m 644 \
		stages/services/files/etc/pam.d/sshd \
		/etc/pam.d

sshd_restart:
	systemctl restart sshd.service

sshd: sshd_config sshd_restart
	@echo "$(ccgreen)Setting up sshd completed$(ccend)"

crons:
	bash stages/services/templates/crons.sh stages/services/files/crons/

laminar:
	install -d /etc/systemd/system/laminar.service.d
	install -D -v -m 644 \
		stages/services/files/etc/systemd/system/laminar.service.d/service.conf \
		/etc/systemd/system/laminar.service.d
	install -D -v -m 755 \
		stages/services/files/usr/local/bin/laminar.run \
		/usr/local/bin
	install -D -v -m 644 \
		stages/services/files/etc/laminar.conf /etc
	chown -R git:git /var/lib/laminar
	systemctl daemon-reload
	@echo "$(ccgreen)Setting up laminar completed$(ccend)"

nginx_sites:
	bash stages/services/templates/nginx/sites/api.sh
	bash stages/services/templates/nginx/sites/bank.sh
	bash stages/services/templates/nginx/sites/blog.sh
	bash stages/services/templates/nginx/sites/ci.sh
	bash stages/services/templates/nginx/sites/dav.sh
	bash stages/services/templates/nginx/sites/default.sh
	bash stages/services/templates/nginx/sites/git.sh
	bash stages/services/templates/nginx/sites/netdata.sh
	bash stages/services/templates/nginx/sites/notifications.sh
	bash stages/services/templates/nginx/sites/podcasts.sh
	bash stages/services/templates/nginx/sites/pics.sh
	bash stages/services/templates/nginx/sites/repo.sh
	bash stages/services/templates/nginx/sites/site.sh
	bash stages/services/templates/nginx/sites/sync.sh
	bash stages/services/templates/nginx/sites/transmission.sh

nginx_test: nginx_sites
	/sbin/nginx -t

nginx_reload: nginx_test
	systemctl reload nginx.service

nginx: nginx_reload
	@echo "$(ccgreen)Setting up nginx completed$(ccend)"

gitea_directory:
	install -d -m 770 --owner git --group git /etc/gitea

gitea_config: /etc/secrets/secrets.json
	bash stages/services/templates/gitea/config.sh
	install -D -m 755 -v stages/services/files/etc/systemd/system/gitea.service /etc/systemd/system
	systemctl daemon-reload

gitea_restart:
	systemctl restart gitea.service

gitea: gitea_directory gitea_config gitea_restart
	@echo "$(ccgreen)Setting up gitea completed$(ccend)"

davfs2:
	bash stages/services/templates/davfs2/secrets.sh
	install -D -m 644 stages/services/files/etc/systemd/system/davfs2-mounts/* /etc/systemd/system
	systemctl daemon-reload
	systemctl enable var-storage-wastebox.automount
	systemctl start var-storage-wastebox.mount
	@echo "$(ccgreen)Setting up davfs2 mounts completed$(ccend)"

podsync:
	install -d -m 750 --owner=syncthing --group=syncthing /etc/podsync
	install -D -m 755 -v stages/services/files/etc/systemd/system/podsync.service /etc/systemd/system
	systemctl daemon-reload
	bash stages/services/templates/podsync/podsync.toml.sh stages/services/variables/services.json
	systemctl restart podsync.service
	@echo "$(ccgreen)Setting up podsync completed$(ccend)"
