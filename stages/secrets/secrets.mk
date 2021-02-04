secrets: directory unpack
	@echo "$(ccgreen)Setting up secrets completed$(ccend)"

directory:
	install -d -m 500 /etc/secrets

unpack: directory
	stages/secrets/files/bin/age -d stages/secrets/files/etc/secrets/secrets.json.age > /etc/secrets/secrets.json
	chmod 400 /etc/secrets/secrets.json
