#!/bin/bash

cd /var/www/

ask() {
# http://djm.me/ask
while true; do
 
if [ "${2:-}" = "Y" ]; then
prompt="Y/n"
default=Y
elif [ "${2:-}" = "N" ]; then
prompt="y/N"
default=N
else
prompt="y/n"
default=
fi
 
# Ask the question - use /dev/tty in case stdin is redirected from somewhere else
read -p "$1 [$prompt] " REPLY </dev/tty
 
# Default?
if [ -z "$REPLY" ]; then
REPLY=$default
fi
 
# Check if the reply is valid
case "$REPLY" in
Y*|y*) return 0 ;;
N*|n*) return 1 ;;
esac
 
done
} 

isd='(?=^.{5,254}$)(^(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'
isa='(?=^.{5,254}$)(^(?:(?!\d+\.)[*a-zA-Z0-9_\-]{1,63}\.?)*(?:(?!\d+\.)[a-zA-Z0-9_\-]{1,63}\.?)+(?:[a-zA-Z]{2,})$)'

md=$(hostname)

echo "servername:    $md"
echo "   aliases:"

for f in *; do
  if [[ -d $f && "$f" != '.' && "$f" != '..' ]]; then
    if [[ $(echo $f | grep -P $isa) != "" ]]; then
	echo "             + $f"
    else
	echo "             - $f (incorect alias)"
    fi
fi
done

read -p "Enter main domain[$md]: " emd
md=${emd:-$md}

read -p "Proxy server[10.10.12.1]: " eproxy
proxy=${eproxy:-10.10.12.1}


if [[ $(echo $md | grep -P $isd) == "" ]]; then
    echo "warning: wrong server name '$md'. Not FQDN"
fi

als=''

for f in *; do
  if [[ -d $f && "$f" != '.' && "$f" != '..' ]]; then
    [[ $(echo $f | grep -P $isa) != "" ]] && yn="Y" || yn="N"
    if ask "Add domain $f" $yn ; then
	als="$als,$f"
    fi
fi
done

als=$(echo $als | sed 's/^,//')

ip=`ifconfig  | grep eth0 -A1 | tail -n1 | sed 's/.*inet addr://g' | sed 's/ .*//g'`

ssh -i /root/.ssh/id_rsa_apache_proxy_vhosts $proxy /usr/local/bin/apache_set_proxy_vhost.sh $ip-$md.conf $md $ip "$als"
