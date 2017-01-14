#!/bin/sh
#echo $1
#sleep 5
#exit
#/usr/local/bin/openfileatline.sh `echo $1 | awk '{ sub(/tmp.fbtmp/carparts.x/, "/var/www/carparts/"); print }'`
#/usr/local/bin/openfileatline.sh `echo $1`
#echo $1 > /tmp/l.log
#exit
domain=`echo $1 | awk '{ sub(/^.*\/tmp\/fbtmp(-[0-9]+)?\//, ""); print}' | awk '{ sub(/\/.*$/, ""); print} '`
echo "request $1" > /tmp/openfileatline_firebug.log
echo "domain $domain" >> /tmp/openfileatline_firebug.log
if [ `echo $domain | awk '{ sub(/^[^\.]+/, ""); print}'` = ".b" ]; then
    mycase='*.b'
    file=`echo $1 | awk '{ sub(/^.*\/tmp\/fbtmp(-[0-9])?\//, ""); print }' `
    dir="/var/www/"`echo $file | awk '{ sub(/\.b\/.*/, ""); print }' `"/"
    file=`echo $file | awk '{ sub(/^.*\.b\//, ""); print }' `
else
    case $domain in
    "myfutureheritage.org" )
mycase='myfutureheritage.org'
    file=`echo $1 | awk '{ sub(/^.*\/tmp\/fbtmp(-[0-9])?\//, ""); print }' `
    dir="/ntaxa/z/fh/"
    file=`echo $file | awk '{ sub(/^.*\myfutureheritage.org\//, ""); print }' `
;;
    "carparts365.ntaxa.com" )
    file=`echo $1 | awk '{ sub(/^.*\/tmp\/fbtmp(-[0-9])?\//, ""); print }' `
    dir="/ntaxa/z/carparts365.ntaxa.com/"
    file=`echo $file | awk '{ sub(/^.*\carparts365.ntaxa.com\//, ""); print }' `
 ;;
    *)
# generic *.z.ntaxa.com domain
    mycase='*.z.ntaxa.com'
    file=`echo $1 | awk '{ sub(/^.*\/tmp\/fbtmp(-[0-9])?\//, ""); print }' `
    dir="/ntaxa/z/"`echo $file | awk '{ sub(/.z.ntaxa.com.*/, ""); print }' `
    file=`echo $file | awk '{ sub(/^.*.z.ntaxa.com./, ""); print }' `
   ;;
esac
fi
line=`echo $file | awk '{ sub(/^[^:]*:/, ""); print }' `
file=`echo $file | awk '{ sub(/:.*$/, ""); print }' `
echo "case $mycase: opening (input: $1, domain $domain, file=$file, dir=$dir, line=$line)" >> /tmp/openfileatline_firebug.log

/usr/local/bin/openfileatlineinnetbeans.sh "$dir/$file" "$line"

