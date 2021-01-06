PACKAGES := $(shell jq -cr '.debian.packages[]' variables/main.json | xargs)

packages: repos
	dpkg-query -s $(PACKAGES) || apt-get install -y $(PACKAGES)
	@printf "`tput bold`Installing Debian packages complete`tput sgr0`"
