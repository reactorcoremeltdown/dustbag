superdistupgrade:
	install -D -m 0644 stages/superdistupgrade/files/etc/apt/sources.list.d/buster.list /etc/apt/sources.list
	DEBIAN_FRONTEND=noninteractive apt-get -y update
	DEBIAN_FRONTEND=noninteractive \
		apt-get \
		-o Dpkg::Options::=--force-confold \
		-o Dpkg::Options::=--force-confdef \
		-y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
		dist-upgrade
	install -D -m 0644 stages/superdistupgrade/files/etc/apt/sources.list.d/bullseye.list /etc/apt/sources.list
	DEBIAN_FRONTEND=noninteractive apt-get -y update
	DEBIAN_FRONTEND=noninteractive \
		apt-get \
		-o Dpkg::Options::=--force-confold \
		-o Dpkg::Options::=--force-confdef \
		-y --allow-downgrades --allow-remove-essential --allow-change-held-packages \
		dist-upgrade
