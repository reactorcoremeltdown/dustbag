MACHINE_ID := $(shell cat /etc/machine-id)

### Garage
ifeq ($(MACHINE_ID), bbb5f20db211480faf15e28f1bf8b015)
secrets: unpack reset_configs
	@echo "$(ccgreen)Setting up secrets completed$(ccend)"

### Fermium
else ifeq ($(MACHINE_ID), 6b2164a96a984edbb8626ed09d87aa66)
secrets: unpack reset_podsync vault_seal
	@echo "$(ccgreen)Setting up secrets completed$(ccend)"

### Other machines
else
secrets: vault_unseal unpack vault_seal
	@echo "$(ccgreen)Setting up secrets completed$(ccend)"

endif

directory:
	getent group secrets || groupadd secrets
	install -d -m 550 /etc/secrets
	chown -R root:secrets /etc/secrets

unpack: directory
	vault-request-unlock && vault-request-key 'secrets-json' 'system' > /etc/secrets/secrets.json.new
	mv /etc/secrets/secrets.json.new /etc/secrets/secrets.json
	chown -R root:secrets /etc/secrets/secrets.json
	chmod 440 /etc/secrets/secrets.json

vault_unlock:
	rbw unlock

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
	bash stages/secrets/templates/grafana.sh
	bash stages/secrets/templates/task-transformer.sh
	@echo "$(ccgreen) Container secrets have been updated"

reset_configs: vault_unlock reset_gmail reset_podsync reset_gitea reset_containers vault_seal
	@echo "$(ccgreen) All configs have been updated"
