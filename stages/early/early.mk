UNAME := $(shell uname)
RETRY := $(shell test -f /etc/default/earlystageconfigs && echo "true")
HOSTNAME := $(shell cat variables/main.json | jq -r .hostname)

ifeq ($(MAKECMDGOALS), builder)
early: test mirrors apt_configs keygen earlystagepackages locales profiles
	echo "provisioning done" > /etc/default/earlystageconfigs;
	@echo "$(ccgreen)Early provisioning stage completed$(ccend)"
else
early: test mirrors vault_unseal apt_configs keygen earlystagepackages locales profiles
	echo "provisioning done" > /etc/default/earlystageconfigs;
	@echo "$(ccgreen)Early provisioning stage completed$(ccend)"
endif

test:
ifeq ($(UNAME), Linux)
	jq --version || apt -y update && apt install -y jq yq git make curl lsb-release
else
	@printf "`tput bold`This operating system is not supported`tput sgr0`\n"
	exit 1
endif

vault_unseal:
	install -D -m 755 stages/early/files/vault-* /usr/local/bin
	install -D -m 755 stages/early/files/rbw-* /usr/local/bin
	/usr/local/bin/vault-request-unlock

apt_configs:
ifneq ($(RETRY), true)
	cp stages/early/files/forceuserdefinedconfigs /etc/apt/apt.conf.d/forceuserdefinedconfigs
	chmod 644 /etc/apt/apt.conf.d/forceuserdefinedconfigs
	chown root:root /etc/apt/apt.conf.d/forceuserdefinedconfigs
endif

mirrors:
ifneq ($(RETRY), true)
	bash -x stages/early/templates/sources.list.sh
endif

keygen:
ifneq ($(RETRY), true)
	test -f /root/.ssh/id_rsa || ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa
endif

earlystagepackages:
ifneq ($(RETRY), true)
	apt update && DEBIAN_FRONTEND=noninteractive apt -o Acquire::ForceIPv4=true install -y dirmngr \
		apt-transport-https \
		certbot \
		lsb-release \
		debian-keyring \
		python3-certbot-dns-cloudflare \
		locales
endif

locales:
ifneq ($(RETRY), true)
	install -D -v -m 644 \
		stages/early/files/locale.gen /etc
	/sbin/locale-gen || /usr/sbin/locale-gen
endif

profiles:
ifneq ($(RETRY), true)
	install -D -v -m 644 \
		stages/early/files/99-bashrc.sh /etc/profile.d
endif
