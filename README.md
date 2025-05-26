# dustbag

Kind of a config management

CI Status: ![](https://ci.rcmd.space/api/badges/rcmd/dustbag/status.svg)

### Motivation

Ansible appears to be too slow and bloated for simple operation like configure once and forget forever. Also running roles separately when only certain changes required is rather challenging. So I decided to give plain old makefiles a try.

### Debian 11 Bullseye roadmap

+ Packages
    + [x] Podman
    + [ ] ~Buildah~ _not needed_
    + [x] Laminar

### Debian 12 Bookworm roadmap

+ [x] `E: The repository 'https://apt.syncthing.net syncthing InRelease' is not signed.`
+ [x] `gocryptfs.service: Failed at step EXEC spawning /usr/bin/gocryptfs: No such file or directory`
+ [x] `E: Unable to locate package laminar`
+ [x] Broken python packages, need to either use virtualenv, or change the install location
+ [x] Fdroid server needs to be shipped as a containers
    + [ ] Package has been removed, now I need to add a container
+ [x] EasyRSA for nginx client certs is not automated
+ [ ] Drone config fails

### Debian 13 Trixie roadmap

+ [x] Retired `hledger`
