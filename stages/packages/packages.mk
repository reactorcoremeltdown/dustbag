ifeq ($(MAKECMDGOALS), production)
	PACKAGES := $(shell yq -r '.debian.essentials[], .debian.server[]' stages/packages/variables/packages.yaml | xargs)
	PYTHON_PACKAGES := $(shell yq -r '.python.server[]' stages/packages/variables/packages.yaml | xargs)
else ifeq ($(MAKECMDGOALS), seedbox)
	PACKAGES := $(shell yq -r '.debian.essentials[]' stages/packages/variables/packages.yaml | xargs)
	PYTHON_PACKAGES := $(shell yq -r '.python.noop[]' stages/packages/variables/packages.yaml | xargs)
else ifeq ($(MAKECMDGOALS), builder)
	PACKAGES := $(shell yq -r '.debian.essentials[], .debian.builder[]' stages/packages/variables/packages.yaml | xargs)
	PYTHON_PACKAGES := $(shell yq -r '.python.noop[]' stages/packages/variables/packages.yaml | xargs)
else
	PACKAGES := $(shell yq -r '.debian.essentials[]' stages/packages/variables/packages.yaml | xargs)
	PYTHON_PACKAGES := $(shell yq -r '.python.noop[]' stages/packages/variables/packages.yaml | xargs)
endif

packages: repos inplace_packages_fix
	dpkg-query -s $(PACKAGES) > /dev/null || DEBIAN_FRONTEND=noninteractive apt-get -o Acquire::ForceIPv4=true install -y $(PACKAGES)
	mkdir -p /opt/virtualenv || true
	python3 -m venv /opt/virtualenv
	/opt/virtualenv/bin/pip3 install $(PYTHON_PACKAGES) || true
	@echo "$(ccgreen)Installing Packages completed$(ccend)"

inplace_packages_fix:
	apt-get -o Acquire::ForceIPv4=true install -y golang-go
	apt-get -y purge yq
