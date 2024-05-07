secrets: directory unpack reset_configs
	@echo "$(ccgreen)Setting up secrets completed$(ccend)"

directory:
	getent group secrets || groupadd secrets
	install -d -m 550 /etc/secrets
	chown -R root:secrets /etc/secrets

unpack: directory
	stages/secrets/files/bin/age-$(shell uname -s)-$(shell uname -m) -d stages/secrets/files/etc/secrets/secrets.json.age > /etc/secrets/secrets.json
	chmod 440 /etc/secrets/secrets.json

remove_config_gmail:
	rm -fr /etc/secrets/gmail_config

reset_gmail: remove_config_gmail misc
	@echo "$(ccgreen) GMail config has been updated"

remove_config_podsync:
	rm -fr /etc/podsync/podsync.toml

reset_podsync: remove_config_podsync podsync
	@echo "$(ccgreen) Podsync config has been updated"

remove_config_gitea:
	rm -fr /etc/gitea/app.ini
	rm -fr /home/git/.config/drone_api_key

reset_gitea: remove_config_gitea gitea_config
	@echo "$(ccgreen) Gitea config has been updated"

reset_containers:
	bash stages/secrets/templates/fsmq.sh
	bash stages/secrets/templates/internal.sh
	bash stages/secrets/templates/task-transformer.sh
	@echo "$(ccgreen) Container secrets have been updated"

reset_configs: reset_gmail reset_podsync reset_gitea reset_containers vault_seal
	@echo "$(ccgreen) All configs have been updated"
