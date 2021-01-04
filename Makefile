all: early firewall repos packages users services

include stages/early/early.mk
include stages/firewall/firewall.mk

repos:
	@echo "Debian repositories"

packages: repos
	@echo "Debian packages"

users: early
	@echo "System users"

services: users packages
	@echo "System services"
