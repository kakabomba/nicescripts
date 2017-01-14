#!/bin/sh

EXTERNAL_IP=$1
LOCAL_NET=$2
#NS_IP='5.9.112.53'



  echo 'applying firewall rules'
#  iptables -F 
  #iptables -D INPUT -j DROP
  iptables -A INPUT -p tcp -d $NS_IP --dport 22 -j ACCEPT
  iptables -A INPUT -p tcp -d $EXTERNAL_IP --dport 22 -j ACCEPT
  iptables -A INPUT -p tcp -d $EXTERNAL_IP --dport 80 -j ACCEPT
  iptables -A INPUT -p tcp -d $EXTERNAL_IP --dport 443 -j ACCEPT
#  iptables -A INPUT -p tcp -d $NS_IP --dport 443 -j ACCEPT
  iptables -A INPUT -p tcp -d $EXTERNAL_IP --dport 8006 -j ACCEPT
#  iptables -A INPUT -p tcp -s 194.44.136.82/32 -j LOG --log-prefix "[netfilter]: [intruser]:" --log-level 6
#  iptables -A INPUT -p tcp -s 10.10.12.131/32 -j LOG --log-prefix "[netfilter]: [tojira]:" --log-level 6
#  iptables -A INPUT -p tcp -d 10.10.12.131/32 -j LOG --log-prefix "[netfilter]: [tojira]:" --log-level 6
#  iptables -A FORWARD -p tcp -d 10.10.12.131/32 -j LOG --log-prefix "[netfilter]: [tojira]:" --log-level 6
#  iptables -A FORWARD -p tcp -s 10.10.12.131/32 -j LOG --log-prefix "[netfilter]: [tojira]:" --log-level 6
#  iptables -A INPUT -j DROP
 
  #Allow smtp server outbound connections
  iptables -A FORWARD -p tcp -s 10.10.12.122/32 --dport 25 -j ACCEPT
  iptables -A FORWARD -p tcp -s $LOCAL_NET -d $NS_IP/32 --dport 25 -j ACCEPT
  iptables -A FORWARD -p tcp -s $LOCAL_NET -d 10.10.12.122/32 --dport 25 -j ACCEPT

#  iptables -A FORWARD -p udp -s 10.10.12.100/32 --dport 53 -j ACCEPT

#  iptables -A FORWARD -p tcp -s 10.10.12.1/32 -d 10.10.12.0/ --dport 80 -j ACCEPT

  #rules to prevent virtual machines from outbound connections
#  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 22 -j LOG --log-prefix "[netfilter]:" --log-level 6 
  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 80 -j LOG --log-prefix "[netfilter]: [80]:" --log-level 6
  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 22 -j LOG --log-prefix "[netfilter]: [22]:" --log-level 6
  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 25 -j LOG --log-prefix "[netfilter]: [25]:" --log-level 6
  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 443 -j LOG --log-prefix "[netfilter]: [443]:" --log-level 6
#  iptables -A FORWARD -p tcp -s 194.44.136.82/32 -j LOG --log-prefix "[netfilter]: [itruser]:" --log-level 6

  iptables -A FORWARD -p tcp -s 10.10.12.182/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.184/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.140/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.172/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.103/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.130/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.131/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.132/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.110/32 -j ACCEPT
  iptables -A FORWARD -p tcp -s 10.10.12.111/32 -j ACCEPT

  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 22 -j DROP
#  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 80 -j DROP
  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 25 -j DROP
#  iptables -A FORWARD -p tcp -s $LOCAL_NET --dport 443 -j DROP

