#!/bin/bash

ff="/images/private/$1"
tf="/images/template/cache/template_from_$1.tar.gz"

echo "copy $tf > $tf."`date '+%F'`".bak"
pv $tf > $tf.`date '+%F'`.bak
echo 'creating new template from vz container 200'
SIZE=`du -sk $ff | cut -f 1`
tar -cf - -C $ff . | pv -p -r -s ${SIZE}k | gzip  > $tf
ls -l1s /images/template/cache/
#tar -czf /images/template/cache/debian-7.0.8-web-mysql_7.0.8_amd64.tar.gz -C $ff .
