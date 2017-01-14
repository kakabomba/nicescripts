#!/bin/sh
echo $1 >> /tmp/openfileatline_firebug.log
echo $2 >> /tmp/openfileatline_firebug.log
/usr/local/netbeans-8.0.2/bin/netbeans --open "$1:$2"
#/usr/local/netbeans-7.4/bin/netbeans --open "$1:$2"
#/usr/local/netbeans-7.3.1/bin/netbeans --open `echo $1 | awk '{ sub(/netbeans:/, ""); print }'`
wmctrl -a NetBeans
exit
