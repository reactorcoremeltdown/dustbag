ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

## GENERIC host (runs by default)
ifeq ($(MACHINE_ROLE),)
DEVICEPING_ID := untrusted-third-party
services: users packages deviceping vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Production host
else ifeq ($(MACHINE_ROLE), production)
CRONS := stages/services/files/crons/main
ROLE := production

services: users packages services_begin motd sshd crons wastebox gitea exported_graphs nginx_sites nginx radicale network_hacks misc podman fdroid deviceping_receiver phockup vault_seal services_end
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Fermium V2, the Pi 4 at home
else ifeq ($(MACHINE_ROLE), homeserver)
CRONS := stages/services/files/crons/fermium
DEVICEPING_ID := deviceping_fermium
ROLE := homeserver

services: users packages services_begin crons nginx_proxies nginx motion dave podsync bootconfig deviceping podman woodpecker_server home_ip snapraid_nas vault_seal mpd services_end
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Seedbox
else ifeq ($(MACHINE_ROLE), seedbox)

services: users packages vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Buildbox
else ifeq ($(MACHINE_ROLE), builder)
ROLE := builder

services: users packages podman drone_runner_amd64 seppuku
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Outpost
else ifeq ($(MACHINE_ROLE), outpost)
ROLE := outpost

services: users packages services_begin podman nginx gotify vault_seal services_end
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## Printserver V2, the Pi Zero W edition
else ifeq ($(MACHINE_ROLE), printserver)
CRONS := stages/services/files/crons/printserver
DEVICEPING_ID := deviceping_printserver
ROLE := printer

services: users packages services_begin crons cups deviceping vault_seal services_end
	@echo "$(ccgreen)Setting up services completed$(ccend)"

## All other hosts
else
services: users packages vault_seal
	@echo "$(ccgreen)Setting up services completed$(ccend)"
endif

##################
## Service targets
##################
services_begin:
	iac begin services

services_end:
	iac end services

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
