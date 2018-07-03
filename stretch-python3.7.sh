#!/bin/bash

echo 'deb http://ftp.de.debian.org/debian testing main' >> /etc/apt/sources.list
apt-get update
sudo apt-get -t testing install python3.7 python3.7-venv

sudo apt-get -t testing install python3.7-dev
sudo apt-get install libxml2-dev libxslt1-dev
