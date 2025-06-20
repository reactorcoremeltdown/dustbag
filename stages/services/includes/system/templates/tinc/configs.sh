#!/usr/bin/env bash

source <(yq -r '.services.tinc | to_entries[] | [.key,(.value|@sh)] | join("=")' stages/services/variables/services.yaml)

install -d -m 0755 /etc/tinc/${netname}
install -d -m 0755 /etc/tinc/${netname}/hosts

test -f /etc/tinc/${netname}/tinc.conf || cat <<EOF > /etc/tinc/${netname}/tinc.conf
Name = ${hostname}
AddressFamily = ipv4
Interface = tun0
EOF

test -f /etc/tinc/${netname}/hosts/${hostname} || cat <<EOF > /etc/tinc/${netname}/hosts/${hostname}
Address = $(dig +short ${fqdn})
Subnet = ${ip}/32
EOF

grep -oq "BEGIN RSA PUBLIC KEY" /etc/tinc/${netname}/hosts/${hostname} || tincd -n ${netname} -K4096

cat <<EOF > /etc/tinc/${netname}/tinc-up
#!/bin/sh
ifconfig \$INTERFACE ${ip} netmask 255.255.255.0
EOF

cat <<EOF > /etc/tinc/${netname}/tinc-down
#!/bin/sh
ifconfig \$INTERFACE down
EOF

chmod +x /etc/tinc/${netname}/tinc-*
