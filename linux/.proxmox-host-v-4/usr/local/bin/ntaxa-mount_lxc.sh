#!/bin/bash

echo "stopping lxc $1"
pct stop $1
sleep 3
echo "umounting $1"
/usr/local/bin/ntaxa-umount_lxc.sh
sleep 3
echo "mounting $1 to /mnt/lxc via /dev/loop5"
losetup /dev/loop5 /images/images/$1/vm-$1-disk-1.raw
mount /dev/loop5 /mnt/lxc
ls -l1sh /mnt/lxc

