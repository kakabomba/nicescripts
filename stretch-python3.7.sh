#!/bin/bash

echo 'deb http://ftp.de.debian.org/debian testing main' >> /etc/apt/sources.list
apt-get update
sudo apt-get -t testing install python3.7
