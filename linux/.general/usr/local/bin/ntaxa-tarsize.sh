#!/bin/bash

fd=$1
tf=$2
SIZE=`du -sk $fd | cut -f 1`
tar -cf - -C $fd . | pv -p -r -s ${SIZE}k | gzip  > $tf
ls $tf
#tar -czf /images/template/cache/debian-7.0.8-web-mysql_7.0.8_amd64.tar.gz -C $ff .
