#!/bin/bash
#
# iptables rules for transparent proxy (tcp gateway)
# trans port needs to be enabled on tor.conf for this to work

NETWORK="192.168.0.0"
NON_TOR=$NETWORK"/24"
TOR_UID="debian-tor"
TRANS_PORT="9040"
INT_IF="ens33"

iptables -t nat -A OUTPUT -o lo -j RETURN
iptables -t nat -A OUTPUT -m owner --uid-owner $TOR_UID -j RETURN
iptables -t nat -A OUTPUT -p udp --dport 53 -j REDIRECT --to-ports 53
for NET in $NON_TOR; do
 iptables -t nat -A OUTPUT -d $NET -j RETURN
 iptables -t nat -A PREROUTING -i $INT_IF -d $NET -j RETURN
done
iptables -t nat -A OUTPUT -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT
iptables -t nat -A PREROUTING -i $INT_IF -p udp --dport 53 -j REDIRECT --to-ports 53
iptables -t nat -A PREROUTING -i $INT_IF -p tcp --syn -j REDIRECT --to-ports $TRANS_PORT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
for NET in $NON_TOR 127.0.0.0/8; do
 iptables -A OUTPUT -d $NET -j ACCEPT
done
iptables -A OUTPUT -m owner --uid-owner $TOR_UID -j ACCEPT
iptables -A OUTPUT -j REJECT
iptables -A OUTPUT -p icmp -j REJECT
iptables -A INPUT -p icmp -j REJECT

