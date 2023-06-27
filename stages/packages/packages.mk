ifeq ($(MAKECMDGOALS), production)
	PACKAGES := $(shell jq -cr '.debian.essentials[], .debian.server[]' stages/packages/variables/packages.json | xargs)
	PYTHON_PACKAGES := $(shell jq -cr '.python.server[]' stages/packages/variables/packages.json | xargs)
else ifeq ($(MAKECMDGOALS), seedbox)
	PACKAGES := $(shell jq -cr '.debian.essentials[]' stages/packages/variables/packages.json | xargs)
	PYTHON_PACKAGES := $(shell jq -cr '.python.noop[]' stages/packages/variables/packages.json | xargs)
else ifeq ($(MAKECMDGOALS), builder)
	PACKAGES := $(shell jq -cr '.debian.essentials[], .debian.builder[]' stages/packages/variables/packages.json | xargs)
	PYTHON_PACKAGES := $(shell jq -cr '.python.noop[]' stages/packages/variables/packages.json | xargs)
else
	PACKAGES := $(shell jq -cr '.debian.essentials[]' stages/packages/variables/packages.json | xargs)
	PYTHON_PACKAGES := $(shell jq -cr '.python.noop[]' stages/packages/variables/packages.json | xargs)
endif

packages: repos
	dpkg-query -s $(PACKAGES) > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y $(PACKAGES)
	mkdir -p /opt/virtualenv || true
	python3 -m venv /opt/virtualenv
	/opt/virtualenv/bin/pip3 install $(PYTHON_PACKAGES) || true
	@echo "$(ccgreen)Installing Packages completed$(ccend)"
