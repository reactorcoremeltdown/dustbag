#!/usr/bin/env bash

IFACE=`ip route | grep default | awk '{print $5}'`
WORLDV4=`yq -r '.shortcuts.worldv4' ${1}`
WORLDV6=`yq -r '.shortcuts.worldv6' ${1}`

### IPv4
cat <<EOF > /etc/firewall/iptables-input
/sbin/iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/iptables -A INPUT -p icmp -j ACCEPT
/sbin/iptables -A INPUT -i lo -j ACCEPT
EOF

yq -r '.rules[] | "/sbin/iptables -A INPUT -i IFACE -p \(.protocol) -s \(.address_v4) --dport \(.port) -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT -m comment --comment \"Allowing \(.name) from \(.address_v4)\""' ${1} | sed "s|IFACE|${IFACE}|g;s|worldv4|${WORLDV4}|g" >> /etc/firewall/iptables-input

cat <<EOF | sed "s|IFACE|${IFACE}|g" >> /etc/firewall/iptables-input
/sbin/iptables -A INPUT -i tun0 -j ACCEPT
/sbin/iptables -A INPUT -i IFACE -j REJECT
EOF

### IPv6
cat <<EOF > /etc/firewall/ip6tables-input
/sbin/ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
/sbin/ip6tables -A INPUT -p ipv6-icmp -j ACCEPT
/sbin/ip6tables -A INPUT -i lo -j ACCEPT
EOF

yq -r '.rules[] | "/sbin/ip6tables -A INPUT -i IFACE -p \(.protocol) -s \(.address_v6) --dport \(.port) -j ACCEPT -m conntrack --ctstate NEW,ESTABLISHED -m comment --comment \"Allowing \(.name) from \(.address_v6)\""' ${1} | sed "s|IFACE|${IFACE}|g;s|worldv6|${WORLDV6}|g" >> /etc/firewall/ip6tables-input

cat <<EOF | sed "s|IFACE|${IFACE}|g" >> /etc/firewall/ip6tables-input
/sbin/ip6tables -A INPUT -i tun0 -j ACCEPT
/sbin/ip6tables -A INPUT -i IFACE -j REJECT
EOF
