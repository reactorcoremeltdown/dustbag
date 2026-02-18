UNAME := $(shell uname)
MACHINE_ARCH := $(shell uname -m)
RETRY := $(shell test -f /etc/default/earlystageconfigs && echo "true")
HOSTNAME := $(shell cat variables/main.json | jq -r .hostname)

ifeq ($(MAKECMDGOALS), builder)
early: iacd test mirrors apt_configs keygen earlystagepackages locales profiles
	date '+%s' > /etc/default/earlystageconfigs;
	@echo "$(ccgreen)Early provisioning stage completed$(ccend)"
else
early: iacd test mirrors vault_unseal apt_configs keygen earlystagepackages locales profiles
	date '+%s' > /etc/default/earlystageconfigs;
	@echo "$(ccgreen)Early provisioning stage completed$(ccend)"
endif

ifeq ($(MACHINE_ARCH), x86_64)
YQ_DOWNLOAD_URL := "https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_amd64"
else ifeq ($(MACHINE_ARCH), armv6l)
YQ_DOWNLOAD_URL := "https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_arm"
else ifeq ($(MACHINE_ARCH), aarch64)
YQ_DOWNLOAD_URL := "https://github.com/mikefarah/yq/releases/download/v4.45.4/yq_linux_arm64"
endif

early_begin:
	iac begin early_stage
	iac stages/early/files/cfg/basic_files.yaml

early_end:
	iac end

iacd:
	test -d /etc/iacd/entities/iac.rcmd.space || mkdir -p /etc/iacd/entities/iac.rcmd.space
	install -D -m 755 stages/early/files/etc/iacd/entities/iac.rcmd.space/* /etc/iacd/entities/iac.rcmd.space

test:
ifeq ($(UNAME), Linux)
	jq --version || apt -y update && apt install -y jq wget git make curl lsb-release
	apt-get purge -y yq
	wget -c $(YQ_DOWNLOAD_URL) -O /usr/local/bin/yq && chmod +x /usr/local/bin/yq
else
	@printf "`tput bold`This operating system is not supported`tput sgr0`\n"
	exit 1
endif

vault_unseal:
	install -D -m 755 stages/early/files/vault-* /usr/local/bin
	install -D -m 755 stages/early/files/rbw-* /usr/local/bin

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
		python3-pip \
		locales
	pip3 install --break-system-packages certbot-dns-hetzner-cloud
endif

locales:
ifneq ($(RETRY), true)
	install -D -v -m 644 \
		stages/early/files/locale.gen /etc
	/sbin/locale-gen || /usr/sbin/locale-gen
endif

profiles:
ifneq ($(RETRY), true)
	install -T -D -v -m 644 \
		stages/early/files/99-bashrc.sh /root/.bash_profile
endif
