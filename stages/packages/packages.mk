PACKAGES := $(shell jq -cr '.debian.packages[]' variables/main.json | xargs)
PACKAGES_LITE := $(shell jq -cr '.debian.packages_lite[]' variables/main.json | xargs)

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || apt-get install -y $(PACKAGES)
	@echo "$(ccgreen)Installing Debian packages complete$(ccend)"

packages_lite: repos
	dpkg-query -s $(PACKAGES_LITE) > /dev/null || apt-get install -y $(PACKAGES_LITE)
	@echo "$(ccgreen)Installing Debian packages complete$(ccend)"
