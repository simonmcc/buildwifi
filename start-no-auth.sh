#!/bin/sh -x

GWDEV=`netstat -nr | grep UG | awk '{ print $8 }'`

iptables -t nat -F 
iptables -t nat -A POSTROUTING -o $GWDEV -j MASQUERADE
#iptables -t nat -A POSTROUTING -o ppp1 -j MASQUERADE
iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
echo 1 > /proc/sys/net/ipv4/ip_forward

echo "Now activate BuildWLANRouter-inside on eth3 and press enter"
read foo

service isc-dhcp-server restart
service dnsmasq restart
