PACKAGES := $(shell jq -cr '.debian.packages[]' variables/main.json | xargs)

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || apt-get install -y $(PACKAGES)
	@printf "`tput bold`Installing Debian packages complete`tput sgr0`\n"
