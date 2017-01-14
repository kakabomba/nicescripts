#!/bin/sh

EXTERNAL_IP=$1
LOCAL_NET=$2
#NS_IP='5.9.112.53'

#virtual ftp?
iptables -A INPUT -p tcp -s $LOCAL_NET -d $LOCAL_NET --dport 22 -j ACCEPT
iptables -t nat -s "$LOCAL_NET" -A POSTROUTING -j MASQUERADE

