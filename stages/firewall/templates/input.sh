#!/usr/bin/env bash

IFACE=`ip route | grep default | awk '{print $5}'`

cat <<EOF > /etc/firewall/iptables-input
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -p icmp -j ACCEPT
/sbib/iptables -A INPUT -i lo -j ACCEPT
EOF

jq -cr '.rules[] | "/sbin/iptables -A INPUT -i IFACE -p \(.protocol) -s \(.address_v4) --dport \(.port) -j ACCEPT -m comment --comment \"Allowing \(.name) from \(.address_v4)\""' ${1} | sed "s|IFACE|${IFACE}|g" >> /etc/firewall/iptables-input

cat <<EOF | sed "s|IFACE|${IFACE}|g" >> /etc/firewall/iptables-input
/sbin/iptables -A INPUT -i tun0 -j ACCEPT
/sbin/iptables -A INPUT -i IFACE -j REJECT
EOF
