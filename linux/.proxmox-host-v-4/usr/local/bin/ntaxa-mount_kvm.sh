#!/bin/bash

imagesdir='/images/images'

mkdir /mnt/kvm/
echo "umounting kvm"
/usr/local/bin/ntaxa-umount_kvm.sh
sleep 3
losetup /dev/loop6 $imagesdir/$1/vm-$1-disk-1.raw
kpartx -a /dev/loop6
vg=$(vgscan | grep 'Found volume group' | grep 'Found volume group "main" using metadata type lvm2' | sed -e 's/^.*"\([^"]*\)".*$/\1/g')
echo "Found volume group $vg"
vgchange -ay
for i in /dev/$vg/*
do
  dir="/mnt/kvm/"$(basename $i)
  echo "creating dir '$dir' and mounting '$i'"
  mkdir $dir
  mount $i $dir
  if [ "$?" -ne "0" ];  then
    echo "cant mount '$i', removing dir '$dir'"
    rmdir $dir
  else
    ls -l1sh $dir
  fi
done

echo "All mounted"
df -h | grep '/mnt/kvm'


