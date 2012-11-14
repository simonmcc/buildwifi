#!/bin/sh

# Routing table entries for each ISP

#echo "1 TT" >> /etc/iproute2/rt_tables
#echo "2 BT" >> /etc/iproute2/rt_tables

# currently ppp0 TalkTalk
#           ppp1 BT Click
DEBUG='echo'
DEBUG=''

TT_DEV=ppp0
TT_NETMASK=255.255.255.255
TT_IP=`ifconfig $TT_DEV | grep 'inet addr' | cut -d: -f 2 | awk '{ print $1}'`
TT_GW=`ifconfig $TT_DEV | grep P-t-P | cut -d: -f 3 | awk '{ print $1}'`

BT_DEV=ppp1
BT_NETMASK=255.255.255.255
BT_IP=`ifconfig $BT_DEV | grep 'inet addr' | cut -d: -f 2 | awk '{ print $1}'`
BT_GW=`ifconfig $BT_DEV | grep P-t-P | cut -d: -f 3 | awk '{ print $1}'`


# individual routing tables
$DEBUG ip route add $TT_IP/$TT_NETMASK dev $TT_DEV src $TT_IP table TT
$DEBUG ip route add default via $TT_GW table TT
$DEBUG ip rule add from $TT_IP table TT

$DEBUG ip route add $BT_IP/$BT_NETMASK dev $BT_DEV src $BT_IP table BT
$DEBUG ip route add default via $BT_GW table BT
$DEBUG ip rule add from $BT_IP table BT

$DEBUG iptables -t nat -F
$DEBUG iptables -t nat -A POSTROUTING -o $TT_DEV -j MASQUERADE
$DEBUG iptables -t nat -A POSTROUTING -o $BT_DEV -j MASQUERADE
$DEBUG iptables -I FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu
echo 1 > /proc/sys/net/ipv4/ip_forward

# del the default route
CURRENT_DEFGW=`netstat -nr | grep ^0.0.0.0`
if [ ! -z "$CURRENT_DEFGW" ]
then
    DEFGW_DEV=`echo $CURRENT_DEFGW|awk '{ print $8 }'`
    $DEBUG route del default dev $DEFGW_DEV
fi
# round-robin on the way out
$DEBUG ip route append default scope global nexthop via $TT_GW dev $TT_DEV weight 1 nexthop via $BT_GW dev $BT_DEV weight 1
