UNAME := $(shell uname)
RETRY := $(shell test -f /etc/default/earlystageconfigs && echo "true")
HOSTNAME := $(shell cat variables/main.json | jq -r .hostname)

early: test shell_history hostname apt_configs keygen earlystagepackages
ifeq ($(UNAME), Linux)
	echo "provisioning done" > /etc/default/earlystageconfigs;
	@printf "`tput bold`Early stage provisioning completed`tput sgr0`"
else
	@printf "`tput bold`This operating system is not supported`tput sgr0`"
	exit 1
endif

test:
	jq --version

shell_history:
ifneq ($(RETRY), true)
	test -L /root/.zsh_history || ln -s /dev/null /root/.zsh_history
	test -L /root/.bash_history || ln -s /dev/null /root/.bash_history
endif

hostname:
ifneq ($(RETRY), true)
	hostnamectl set-hostname $(HOSTNAME)
endif

apt_configs:
ifneq ($(RETRY), true)
	cp stages/early/files/forceuserdefinedconfigs /etc/apt/apt.conf.d/forceuserdefinedconfigs
	chmod 644 /etc/apt/apt.conf.d/forceuserdefinedconfigs
	chown root:root /etc/apt/apt.conf.d/forceuserdefinedconfigs
endif

keygen:
ifneq ($(RETRY), true)
	test -f /root/.ssh/id_rsa || ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa
endif

earlystagepackages:
ifneq ($(RETRY), true)
	apt update && apt install dirmngr \
		apt-transport-https \
		certbot \
		python3-certbot-dns-cloudflare
endif
