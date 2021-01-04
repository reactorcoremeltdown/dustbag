UNAME := $(shell uname)
HOSTNAME := "buster.rcmd.space"

early: test shell_history hostname apt_configs keygen earlystagepackages
ifeq ($(UNAME), Linux)
	@echo "Early stage"
	echo "provisioning done" > /etc/default/earlystageconfigs; \
else
	@echo "This operating system is not supported"
	exit 1
endif

test:
	jq --version

shell_history:
	test -f /root/.zsh_history || ln -s /dev/null /root/.zsh_history
	test -f /root/.bash_history || ln -s /dev/null /root/.bash_history

hostname:
	hostnamectl set-hostname $(HOSTNAME)

apt_configs:
	cp files/forceuserdefinedconfigs /etc/apt/apt.conf.d/forceuserdefinedconfigs
	chmod 644 /etc/apt/apt.conf.d/forceuserdefinedconfigs
	chown root:root /etc/apt/apt.conf.d/forceuserdefinedconfigs

keygen:
	test -f /root/.ssh/id_rsa || ssh-keygen -t rsa -N '' -f /root/.ssh/id_rsa

earlystagepackages:
	apt update && apt install dirmngr \
		apt-transport-https \
		certbot \
		python3-certbot-dns-cloudflare
