#!/bin/bash

WEB_IP=$1
WORKERS_NET=$2
COMMAND=$3

echo 'applying preroute rules'

if [[ "$COMMAND" = "dns" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p udp -d $WEB_IP --dport 53 -j DNAT --to-destination "$WORKERS_NET".121:53
fi

#if [[ "$COMMAND" = "smtp" ]] || [[ "$COMMAND" = "" ]]; then
#  iptables -t nat -A PREROUTING -p tcp -d $WEB_IP --dport 25 -j DNAT --to-destination "$WORKERS_NET".122:25
#  iptables -t nat -A PREROUTING -p tcp -d $WEB_IP --dport 465 -j DNAT --to-destination "$WORKERS_NET".122:25
#  iptables -t nat -A PREROUTING -p tcp -d $WEB_IP --dport 587 -j DNAT --to-destination "$WORKERS_NET".122:25
#  iptables -t nat -A PREROUTING -p tcp -d $NS_IP --dport 25 -j DNAT --to-destination "$WORKERS_NET".122:25
#  iptables -t nat -A PREROUTING -p tcp -d $NS_IP --dport 465 -j DNAT --to-destination "$WORKERS_NET".122:25
#  iptables -t nat -A PREROUTING -p tcp -d $NS_IP --dport 587 -j DNAT --to-destination "$WORKERS_NET".122:25
#fi

if [[ "$COMMAND" = "pop3" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP --dport 110 -j DNAT --to-destination "$WORKERS_NET".122:110
fi

if [[ "$COMMAND" = "pop3s" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP --dport 995 -j DNAT --to-destination "$WORKERS_NET".122:995
fi

if [[ "$COMMAND" = "imap" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP  --dport 143 -j DNAT --to-destination "$WORKERS_NET".122:143
fi

if [[ "$COMMAND" = "imaps" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP  --dport 993 -j DNAT --to-destination "$WORKERS_NET".122:993
fi

if [[ "$COMMAND" = "src" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP  --dport 22 -j DNAT --to-destination "$WORKERS_NET".132:22
fi

if [[ "$COMMAND" = "ntop" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p tcp -d $WEB_IP  --dport 3333 -j DNAT --to-destination 127.0.0.1:3000
fi

if [[ "$COMMAND" = "ldap" ]] || [[ "$COMMAND" = "" ]]; then
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP  --dport 389 -s $MAKARONY_IP -j DNAT --to-destination "$WORKERS_NET".130:389
  iptables -t nat -A PREROUTING -p udp -d $NS_IP  --dport 389 -s $MAKARONY_IP -j DNAT --to-destination "$WORKERS_NET".130:389
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP  --dport 389 -s $WEB_IP -j DNAT --to-destination "$WORKERS_NET".130:389
  iptables -t nat -A PREROUTING -p udp -d $NS_IP  --dport 389 -s $WEB_IP -j DNAT --to-destination "$WORKERS_NET".130:389
  iptables -t nat -A PREROUTING -p tcp -d $NS_IP  --dport 389 -s $NS_IP -j DNAT --to-destination "$WORKERS_NET".130:389
  iptables -t nat -A PREROUTING -p udp -d $NS_IP  --dport 389 -s $NS_IP -j DNAT --to-destination "$WORKERS_NET".130:389
fi


