PACKAGES := $(shell jq -cr '.debian.packages[]' stages/packages/variables/packages.json | xargs)
PACKAGES_LITE := $(shell jq -cr '.debian.packages_lite[]' stages/packages/variables/packages.json | xargs)

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y $(PACKAGES)
	pip3 install --upgrade youtube-dl tqdm==4.62.2
	@echo "$(ccgreen)Installing Debian packages completed$(ccend)"

packages_lite: repos
	dpkg-query -s $(PACKAGES_LITE) > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y $(PACKAGES_LITE)
	@echo "$(ccgreen)Installing Debian packages completed$(ccend)"
