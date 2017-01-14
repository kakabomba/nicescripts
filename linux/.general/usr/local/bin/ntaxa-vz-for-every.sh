#!/bin/bash

rd=`tput setaf 1`
bl=`tput setaf 7`
rst=`tput sgr0`

cd /images/private
for i in *; do 
    hn=$(cat $i/etc/hostname)
    command=$(echo "$@" | sed -e 's/%i/'$i'/g' -e 's/%n/'$hn'/g')
    echo  -e "\033[33;5m------ $i-$hn\033[0m"
    echo "${rd}------ $command${rst}"
    if [[ "${0##*/}" == 'ntaxa-vz-exex-in-every.sh' ]]; then
	vzctl exec $i "$command"
    else
	eval $command
    fi
    echo ''
done
