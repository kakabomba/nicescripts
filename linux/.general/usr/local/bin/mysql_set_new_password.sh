#!/bin/bash

echo "stoping mysql"
service mysql stop
sleep 3
echo "starting mysql without greants"
mysqld_safe --skip-grant-tables &
sleep 3
echo "changing password to '$1'"
echo "update user set password=PASSWORD('$1') where User='root'; flush privileges;" | mysql -u root mysql
sleep 1
echo "stoping mysql in safe mode"
service mysql stop
sleep 3
echo "starting mysql"
service mysql start
sleep 1
echo "Testing: SHOW DATABASES;"
echo "SHOW DATABASES;" | mysql -u root --password=$1
