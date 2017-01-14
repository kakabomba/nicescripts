#!/bin/bash


f=150
t=200
ch="a-zA-Z0-9_-"
#a="\\(\\(*\\.\\)|\\([$ch][-$ch]\\).\\)*[$ch][-$ch]\\{1,50\\}.[$ch]\{1,30\}\$"
onel="\\(\\(\\([$ch]\\{1,30\\}\\)\\|\\(\\*\\)\\)\\.\\)"
a="^$onel*\\([$ch]\\{1,30\\}\\.\\)[$ch]\\{1,10\\}\$"
ddir='aliases'
ddirweb='aliasesweb'

rm -r "/root/$ddir/"*
rm -r "/root/$ddirweb/"*

ddir="/root/$ddir"
ddirweb="/root/$ddirweb"

fw () 
{
	vma=$1
        hna=$2
	ipa=$3
	alsa=$4
    aliasfilename="$ddir/$vma/$hna.aliases.conf"
	  echo "+	Writing file $aliasfilename for $vma"
          echo "#Alias to redirect to $vma($ipa)
<VirtualHost *:80>
 ServerName $hna
 $alsa

 ProxyRequests Off
 ProxyPreserveHost On

 <Proxy *>
 Order deny,allow
 Allow from all
 </Proxy>
 ProxyPass / http://$ipa:80/ retry=0
 ProxyPassReverse / http://$ipa:80/ retry=0
 <Location />
 Order allow,deny
 Allow from all
 </Location>
</VirtualHost>
<VirtualHost *:443>
 ServerName $ipa
 $alsa

 ProxyRequests Off
 ProxyPreserveHost on
 SSLProxyEngine on
 SSLEngine on
 SSLCertificateFile /etc/ssl/certs/ssl-cert-snakeoil.pem
 SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key

 <Proxy *>
 Order deny,allow
 Allow from all
 </Proxy>
 ProxyPass / http://$ipa:443/
 ProxyPassReverse / http://$ipa:443/
 <Location />
 Order allow,deny
 Allow from all
 </Location>
</VirtualHost>" > $aliasfilename
  return 0
}

html () 
{
  vma=$1
  hna=$2
  ipa=$3
  alsa=$4
  echo "ServerName $hna$alsa" > "$ddirweb/$vma/$hna"
  return 0
}


for vmpath in /images/private/*; do
  vm=`basename $vmpath`
  if [[ $vm -ge "$f" && $vm -le "$t" ]]; then
    vmhostshort=`cat /images/private/$vm/etc/hostname`
    vmhost=$vmhostshort".a.ntaxa.com"
    mkdir $ddir/$vm-$vmhostshort
    mkdir $ddirweb/$vm-$vmhostshort
    fw $vm-$vmhostshort $vmhost 10.10.12.$vm "" 
    html $vm-$vmhostshort $vmhost 10.10.12.$vm "" 
    echo "Include aliases/$vm-$vmhostshort/" > "$ddir/include-$vm-$vmhostshort.conf"
    echo "+scaning hosts in $vmpath"
    for hostpath in /images/private/$vm/var/www/*; do
      host=`basename $hostpath`
      allals=''
      if [[ -d $hostpath ]]; then
        echo "+	scaning aliases files for $hostpath"
        for aliasfilepath in /images/private/$vm/var/www/$host/config/aliases*.conf; do
          aliasfile=`basename $aliasfilepath`
          als=''
          while read fline; do
	    line=`echo $fline | grep '^Server\(Name\|Alias\) ' | sed 's/^Server\(Name\|Alias\) *//g'`
	    if [[ "$line" == "" ]]; then
	      echo "-		skiping line $fline"
	    else
	      echo "+		reading line $fline"
	      for domain in $line; do
		check=`echo $domain | sed "s/$a//"`
		if [[ "$check"  == "" ]]; then
		    echo "+			ok $domain"
                    als=$als' '$domain
		else
		    echo "-			skiping wrong domain $domain"
		fi
	      done
	    fi
          done <$aliasfilepath
          if [[ "$als" == "" ]]; then
	    echo "-		no aliases in file $aliasfilepath"
  	  else
	    allals="$allals
 ServerAlias $als"    
	  fi
        done
        fw $vm-$vmhostshort $host 10.10.12.$vm "$allals"
        html $vm-$vmhostshort $host 10.10.12.$vm "$allals" $vmhostshort
      else
        echo "-	skiping $hostpath (not directory)"
      fi
      
    done
  else
    echo "-skiping $vmpath (not in $f-$t range)"
  fi
done

newmd5=$(find /root/aliases/ -xtype f -print0 | xargs -0 sha1sum | cut -b-40 | sort | sha1sum)
oldmd5=$(find /etc/apache2/aliases/ -xtype f -print0 | xargs -0 sha1sum | cut -b-40 | sort | sha1sum)

echo "new aliases md5: $newmd5"
echo "old aliases md5: $oldmd5"

if [[ "$newmd5" == "$oldmd5" ]]; then
  echo 'md5 are the same'
else
  echo 'md5 differ'
  rsync -r --force --del /root/aliases/ /etc/apache2/aliases/
  rsync -r --force --del /root/aliasesweb/ /var/www/aliases/
  sleep 3
  /usr/sbin/service apache2 restart 2>&1
fi
#rsync -r --force --del -e ssh /root/aliases/ root@proxy:/etc/apache2/aliases/
#ssh root@proxy service apache2 restart
