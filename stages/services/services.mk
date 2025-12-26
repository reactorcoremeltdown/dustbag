ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

## GENERIC host (runs by default)
ifeq ($(MAKECMDGOALS),)
DEVICEPING_ID := untrusted-third-party
services: users packages deviceping vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Production host
else ifeq ($(MAKECMDGOALS), production)
CRONS := stages/services/files/crons/main
ROLE := production

services: users packages motd sshd crons dave wastebox gitea exported_graphs nginx_sites nginx radicale tinc network_hacks misc podman fdroid deviceping_receiver phockup drone_server drone_runner_amd64 vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Fermium V2, the Pi 4 at home
else ifeq ($(MAKECMDGOALS), fermium)
CRONS := stages/services/files/crons/fermium
DEVICEPING_ID := deviceping_fermium
ROLE := homeserver

services: users packages crons nginx_proxies nginx tinc_client mpd motion podsync bootconfig deviceping drone_runner_arm pki home_ip snapraid_nas vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Seedbox
else ifeq ($(MAKECMDGOALS), seedbox)

services: users packages drone_runner_amd64 vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Buildbox
else ifeq ($(MAKECMDGOALS), builder)
ROLE := builder

services: users packages podman drone_runner_amd64 seppuku
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Outpost
else ifeq ($(MAKECMDGOALS), outpost)
ROLE := outpost

services: users packages podman drone_runner_amd64 tinc_client nginx_packages nginx_certificates nginx_configs gotify vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Printserver V2, the Pi Zero W edition
else ifeq ($(MAKECMDGOALS), printserver)
CRONS := stages/services/files/crons/printserver
DEVICEPING_ID := deviceping_printserver
ROLE := printer

services: users packages crons cups deviceping drone_runner_arm vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## All other hosts
else
services: users packages vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"
endif

##################
## Service targets
##################

home_ip:
	install -D -m 755 stages/services/files/usr/local/bin/home-ip /usr/local/bin

misc:
	install -D -m 755 stages/services/files/usr/local/bin/rcmd-space-stats /usr/local/bin
	install -D -m 755 stages/services/files/usr/local/bin/kanboard-stats /usr/local/bin
	install -D -m 755 stages/services/files/usr/local/src/rcmd-functions.mk /usr/local/src
	test -f /etc/secrets/gmail_config || (vault-request-unlock && vault-request-key gmail_config tasks > /etc/secrets/gmail_config && chmod 400 /etc/secrets/gmail_config)
	@echo "$(ccgreen)Setting up misc scripts completed$(ccend)"

vault_seal:
	/usr/local/bin/vault-request-lock

include stages/services/includes/nginx/nginx.mk
include stages/services/includes/system/system.mk
include stages/services/includes/system/birdhouse.mk
include stages/services/includes/monitoring/monitoring.mk
include stages/services/includes/cicd/cicd.mk
include stages/services/includes/media/media.mk
