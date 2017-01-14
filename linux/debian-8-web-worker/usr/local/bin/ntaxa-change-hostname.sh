#!/bin/bash

old=`cat /etc/hostname`
if [[ "$1" == '' ]]; then
  echo "no hostname given"
  exit
fi

echo "change $old=>$1"

echo $1 > /etc/hostname

sed -i "s/$old/$1/g" /etc/hosts

echo "--- /etc/hostname"

cat /etc/hostname

echo "--- /etc/hosts"

cat /etc/hosts

/etc/init.d/hostname.sh start


