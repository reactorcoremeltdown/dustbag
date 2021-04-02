PACKAGES := $(shell jq -cr '.debian.packages[]' stages/packages/variables/packages.json | xargs)
PACKAGES_LITE := $(shell jq -cr '.debian.packages_lite[]' stages/packages/variables/packages.json | xargs)

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || apt-get install -y $(PACKAGES)
	pip3 install --upgrade youtube-dl
	@echo "$(ccgreen)Installing Debian packages completed$(ccend)"

packages_lite: repos
	dpkg-query -s $(PACKAGES_LITE) > /dev/null || apt-get install -y $(PACKAGES_LITE)
	@echo "$(ccgreen)Installing Debian packages completed$(ccend)"
