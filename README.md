# dustbag

Kind of a config management

CI Status: ![](https://ci.rcmd.space/badge/dustbag.svg)

### Motivation

Ansible appears to be too slow and bloated for simple operation like configure once and forget forever. Also running roles separately when only certain changes required is rather challenging. So I decided to give plain old makefiles a try.

### Debian 11 Bullseye roadmap

+ Packages
    + [x] Podman
    + [ ] ~Buildah~ _not needed_
    + [x] Laminar
