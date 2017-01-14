#!/bin/bash

EXTERNAL_IP=$1
WORKERS_PREFIX=$2
COMMAND=$3

echo 'applying preroute rules i for workers'

iptables -t nat -A PREROUTING -p tcp -d 10.10.10.1 --dport 80 -j DNAT --to-destination 10.10.10.230:80
#iptables -t nat -A PREROUTING -p tcp -d 10.10.10.1 --dport "1026" -j DNAT  --to-destination 10.10.11.232:22
#iptables -t nat -A POSTROUTING  -d 10.10.10.230 -j SNAT --to-source 10.10.10.1
#iptables -t nat -A POSTROUTING -p tcp -d 10.10.10.230 -j SNAT --to-source 10.10.10.1

#exit

if [[ "$COMMAND" = "ssh" ]] || [[ "$COMMAND" = "" ]]; then
  for i in {100..250}; do 
      iptables -t nat -A PREROUTING -p tcp --destination 10.10.10.1 --dport "22$i" -j DNAT --to-destination "$WORKERS_PREFIX""$i":22
  done
fi

if [[ "$COMMAND" = "mysql" ]] || [[ "$COMMAND" = "" ]]; then
  for i in {100..250}; do 
      iptables -t nat -A PREROUTING -p tcp -d $EXTERNAL_IP --dport "33$i" -j DNAT --to-destination "$WORKERS_PREFIX""$i":3306
  done
fi

if [[ "$COMMAND" = "postgres" ]] || [[ "$COMMAND" = "" ]]; then
  for i in {100..250}; do 
      iptables -t nat -A PREROUTING -p tcp -d $EXTERNAL_IP --dport "54$i" -j DNAT --to-destination "$WORKERS_PREFIX""$i":5432
  done
fi

if [[ "$COMMAND" = "ftp" ]] || [[ "$COMMAND" = "" ]]; then
  for i in {100..250}; do 
      iptables -t nat -A PREROUTING -p tcp -d $EXTERNAL_IP --dport "21$i" -j DNAT --to-destination "$WORKERS_PREFIX""$i":21
  done
fi

#iptables -t nat -A POSTROUTING -p tcp -d "$WORKERS_PREFIX""0/24" -j SNAT --to-source 10.10.10.1 #такий спосіб блокує можливість налаштовувати iptables на віртуальних машинах бо всі пакети мають змінений source ip на 10.10.10.1

iptables -A FORWARD -p tcp -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT

