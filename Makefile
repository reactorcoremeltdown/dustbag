all: early packages users services

production: early firewall repos packages users services monitoring last

fermium: early repos packages users services

seedbox: early users services

printserver: early packages services

include variables/colors.mk
include variables/globalvars.mk
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
