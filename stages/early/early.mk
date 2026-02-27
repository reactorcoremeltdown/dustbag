UNAME := $(shell uname)
MACHINE_ARCH := $(shell uname -m)
RETRY := $(shell test -f /etc/default/earlystageconfigs && echo "true")
HOSTNAME := $(shell cat variables/main.json | jq -r .hostname)

ifeq ($(MAKECMDGOALS), builder)
early: iacd test mirrors apt_configs keygen earlystagepackages locales profiles
	date '+%s' > /etc/default/earlystageconfigs;
	@echo "$(ccgreen)Early provisioning stage completed$(ccend)"
else
early: early_begin iacd test mirrors vault_unseal apt_configs keygen earlystagepackages locales profiles early_end
	date '+%s' > /etc/default/earlystageconfigs;
	@echo "$(ccgreen)Early provisioning stage completed$(ccend)"
endif

ifeq ($(MACHINE_ARCH), x86_64)
CORE_BINARIES_CONFIG := "stages/early/files/cfg/core_binaries_amd64.yaml"
else ifeq ($(MACHINE_ARCH), armv6l)
CORE_BINARIES_CONFIG := "stages/early/files/cfg/core_binaries_armhf.yaml"
else ifeq ($(MACHINE_ARCH), aarch64)
CORE_BINARIES_CONFIG := "stages/early/files/cfg/core_binaries_arm64.yaml"
endif

early_begin:
	iac begin early_stage

early_end:
	iac end early_stage

iacd:
	test -d /etc/iacd/entities/iac.rcmd.space || mkdir -p /etc/iacd/entities/iac.rcmd.space
	install -D -m 755 stages/early/files/etc/iacd/entities/iac.rcmd.space/* /etc/iacd/entities/iac.rcmd.space

test:
ifeq ($(UNAME), Linux)
	iac stages/early/files/cfg/core_packages.yaml
	iac $(CORE_BINARIES_CONFIG)
else
	@printf "`tput bold`This operating system is not supported`tput sgr0`\n"
	exit 1
endif

vault_unseal:
	iac stages/early/files/cfg/vault_binaries.yaml

apt_configs:
	iac stages/early/files/cfg/apt_configs.yaml

mirrors:
ifneq ($(RETRY), true)
	bash -x stages/early/templates/sources.list.sh
endif

keygen:
ifneq ($(RETRY), true)
	test -f /root/.ssh/id_rsa || ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa
endif

earlystagepackages:
	iac stages/early/files/cfg/required_packages.yaml
ifneq ($(RETRY), true)
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
