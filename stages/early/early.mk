UNAME := $(shell uname)
RETRY := $(shell test -f /etc/default/earlystageconfigs && echo "true")
HOSTNAME := $(shell cat variables/main.json | jq -r .hostname)

early: test mirrors apt_configs keygen earlystagepackages locales profiles
	echo "provisioning done" > /etc/default/earlystageconfigs;
	@echo "$(ccgreen)Early provisioning stage completed$(ccend)"

test:
ifeq ($(UNAME), Linux)
	jq --version || apt install -y jq
else
	@printf "`tput bold`This operating system is not supported`tput sgr0`\n"
	exit 1
endif

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
	/sbin/locale-gen
endif

profiles:
ifneq ($(RETRY), true)
	install -D -v -m 644 \
		stages/early/files/99-bashrc.sh /etc/profile.d
endif
