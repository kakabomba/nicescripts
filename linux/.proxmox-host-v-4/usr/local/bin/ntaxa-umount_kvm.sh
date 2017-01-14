#!/bin/bash

for i in /mnt/kvm/*
do
  umount -l $i
done

vg=$(vgscan | grep -v 'Found volume group "main" using metadata type lvm2' | sed -e 's/^.*"\([^"]*\)".*$/\1/g')

if [ "$vg" != "" ]; then
  vgchange -an $vg
fi
kpartx -d /dev/loop6

for i in /mnt/kvm/*
do
  rmdir /mnt/kvm/$(basename $i)
done

losetup -d /dev/loop6

