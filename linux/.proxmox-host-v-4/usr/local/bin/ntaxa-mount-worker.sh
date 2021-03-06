#!/bin/bash


mkdir /mnt/workers/
mkdir /mnt/workers/$1
echo "umounting kvm"
/usr/local/bin/ntaxa-umount-worker.sh $1
sleep 3
losetup /dev/loop6 /images/images/$1/vm-$1-disk-1.raw
kpartx -a /dev/loop6
vg=$(vgscan | grep 'Found volume group "main" using metadata type lvm2' | sed -e 's/^.*"\([^"]*\)".*$/\1/g')
echo "Found volume group $vg"
vgchange -ay
for i in /dev/$vg/*
do
  dir="/mnt/workers/$1/"$(basename $i)
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
df -h | grep '/mnt/workers/$1'


