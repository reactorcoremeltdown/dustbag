secrets: directory unpack
	@printf "`tput bold`Setting up secrets completed`tput sgr0`\n"

directory:
	install -d -m 500 /etc/secrets

unpack: directory
	stages/secrets/files/bin/age -d stages/secrets/files/etc/secrets/secrets.json.age > /etc/secrets/secrets.json
	chmod 400 /etc/secrets/secrets.json
