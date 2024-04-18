secrets: directory unpack reset_gmail
	@echo "$(ccgreen)Setting up secrets completed$(ccend)"

directory:
	groupadd secrets
	install -d -m 550 /etc/secrets
	chown -R root:secrets /etc/secrets

unpack: directory
	stages/secrets/files/bin/age-$(shell uname -s)-$(shell uname -m) -d stages/secrets/files/etc/secrets/secrets.json.age > /etc/secrets/secrets.json
	chmod 440 /etc/secrets/secrets.json

remove_config_gmail:
	rm -fr /etc/secrets/gmail_config

reset_gmail: remove_config_gmail misc
	@echo "$(ccgreen) GMail config has been updated"
