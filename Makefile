all: early packages users services

builder: early packages users services

outpost: early packages users services monitoring

production: early firewall repos packages users services monitoring last

fermium: lock early repos packages users services monitoring unlock

seedbox: early users services

printserver: lock early packages services monitoring unlock

birdhouse: birdhouse-setup

include variables/colors.mk
include variables/globalvars.mk
include stages/lock/lock.mk
include stages/early/early.mk
include stages/firewall/firewall.mk
include stages/repos/repos.mk
include stages/packages/packages.mk
include stages/users/users.mk
include stages/secrets/secrets.mk
include stages/services/services.mk
include stages/monitoring/monitoring.mk
include stages/last/last.mk
include stages/superdistupgrade/superdistupgrade.mk
