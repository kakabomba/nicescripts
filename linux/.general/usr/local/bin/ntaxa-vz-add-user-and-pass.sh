#!/bin/bash

if [[ "$2" == '' ]]; then
    echo "usage $0 NUMBER user"
    exit
fi
comm="useradd $2 -m -p "'`mkpasswd '"$2"'`'"; chage -d0 '$2'; sudo adduser $2 sudo; sed -i -e 's/^PermitRootLogin.*/PermitRootLogin no/g' /etc/ssh/sshd_config; service ssh restart"
echo $comm
#exit
vzctl exec $1 $comm
