#!/bin/sh

rulez='/etc/ntaxa-fw'

IP_OUT=$(cat $rulez/out_ip)
WORKERS=$(cat $rulez/workers_net)
LOCAL=$(cat $rulez/local_net)


/etc/ntaxa-fw/rules.localnet.sh  $IP_OUT $LOCAL
/etc/ntaxa-fw/rules.workers.sh   $IP_OUT $WORKERS
#./rules.firewall $WEB $LOCAL
#./rules.custom   $WEB $LOCAL

iptables -t nat -L --line-numbers -n
iptables -t filter -L --line-numbers -n
iptables -t mangle -L --line-numbers -n

