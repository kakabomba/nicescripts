#!/bin/sh
#xcalc

domain=`echo $1 | awk '{ sub(/netbeans:\/\//, ""); print}' | awk '{ sub(/\/.*$/, ""); print} '`
echo "$1: domain=$domain" > /tmp/openfileatline_firebug.log

if [ `echo $domain | awk '{ sub(/^[^\.]+/, ""); print}'` = ".b" ]; then
    mycase="*.b"
#    fileline=`echo $1 | awk '{ sub(/netbeans:\/\//, ""); print }' `
    fileline=`echo $1 | awk '{ sub(/^.*\.b\//, ""); print }' `
    dir='/' #`echo $fileline | awk '{ sub(/\.b\/.*/, ""); print }' `

else
  if [ $domain = "myfutureheritage.org" ]; then
    mycase='myfutureheritage.org'
    fileline=`echo $1 | awk '{ sub(/netbeans:\/\//, ""); print }' `
    dir='/ntaxa/z/fh/'`echo $fileline | awk '{ sub(/\.b\/.*/, ""); print }' `
    fileline=`echo $fileline | awk '{ sub(/^.*\.b\//, ""); print }' `
  else
    if [ `echo $domain | awk '{ sub(/^[^\.]+/, ""); print}'` = ".z.ntaxa.com" ]; then
      mycase='*.z.ntaxa.com'
      fileline=`echo $1 | awk '{ sub(/netbeans:\/\//, ""); print }' | awk '{ sub(/\/ntaxa\/z/, ""); print }'`
      dir="/ntaxa/z/"`echo $fileline | awk '{ sub(/.z.ntaxa.com.*/, ""); print }' `
      fileline=`echo $fileline | awk '{ sub(/^.*.z.ntaxa.com\/[^\/]+/, ""); print }' `
    else
      mycase='no domain? just local file passed?'
      fileline=`echo $1 | awk '{ sub(/netbeans:\/\//, ""); print }'`
      dir=''
      fileline=`echo $fileline | awk '{ sub(/^\//, ""); print }' `
    fi
  fi
fi

line=`echo $fileline | awk '{ sub(/^[^:]*:/, ""); print }' `
file=`echo $fileline | awk '{ sub(/:.*$/, ""); print }' `

echo "case $mycase: opening (fileline=$fileline, dir=$dir, file=$file, line=$line)" >> /tmp/openfileatline_firebug.log

/usr/local/bin/openfileatlineinnetbeans.sh $dir/$file $line

exit
