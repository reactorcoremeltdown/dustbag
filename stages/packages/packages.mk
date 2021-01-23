PACKAGES := $(shell jq -cr '.debian.packages[]' variables/main.json | xargs)
PACKAGES_LITE := $(shell jq -cr '.debian.packages_lite[]' variables/main.json | xargs)

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || apt-get install -y $(PACKAGES)
	@printf "`tput bold`Installing Debian packages complete`tput sgr0`\n"

packages_lite: repos
	dpkg-query -s $(PACKAGES_LITE) > /dev/null || apt-get install -y $(PACKAGES_LITE)
	@printf "`tput bold`Installing Debian packages complete`tput sgr0`\n"
