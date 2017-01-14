#!/bin/bash

function pause(){
   read -p "$*"
}

#localh="localhost/db1"
#remoteh="remotehost/db2"

if [ "$1" == "-h" ]
    then
    echo "$0 host1/db1 host2/db2"
    exit
fi

IFS='/' read -a Array <<< "$1"
localh="${Array[0]}"
localdb="${Array[1]}"

IFS='/' read -a Array <<< "$2"
remoteh="${Array[0]}"
remotedb="${Array[1]}"

echo "comparing $localh/$localdb and $remoteh/$remotedb"

#consolewidth=$(( $(tput cols) - 2 ))

#difffw="diff -wy --suppress-common-lines -W $consolewidth"

bakdir="/tmp"
scriptdir=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

date=`date +"%y_%m_%d___%H_%M"`
echo $date

localf="$bakdir/$localh""_$localdb""_schema_$date.sql"
remotef="$bakdir/$remoteh""_$remotedb""_schema_$date.sql"
localfdb="$bakdir/$localh""_$localdb""_$date.sql"
remotefdb="$bakdir/$remoteh""_$remotedb""_$date.sql"

echo "dump $localh/$localdb schema"
pg_dump -s -U postgres --password -h $localh $localdb > $localf
echo "done"
ls -l1sh $localf
echo '--------------------------------------------------------------'
echo ''

echo "dump $remoteh/$remotedb schema"
pg_dump -s -U postgres --password -h $remoteh $remotedb > $remotef
ls -l1sh $remotef
echo '--------------------------------------------------------------'
echo ''

pause "change $remoteh/$remotedb->$localh/$localdb structure - sql to run on $remoteh/$remotedb in order to lead it to $localh/$localdb structure"
java -jar "$scriptdir/apgdiff-2.4.jar" $remotef $localf
echo '--------------------------------------------------------------'
echo ''

pause "change $localh/$localdb->$remoteh/$remotedb structure - sql to run on $localh/$localdb in order to lead it to $remoteh/$remotedb structure"
java -jar "$scriptdir/apgdiff-2.4.jar" $localf $remotef
echo '--------------------------------------------------------------'
echo ''

echo "dump $localh/$localdb full db"
pg_dump -U postgres --password -h $localh $localdb > $localfdb
echo "done"
ls -l1sh $localfdb
echo '--------------------------------------------------------------'
echo ''

echo "dump $remoteh/$remotedb full db"
pg_dump -U postgres --password -h $remoteh $remotedb > $remotefdb
echo "done"
ls -l1sh $remotefdb
echo '--------------------------------------------------------------'
echo ''

echo "copy $remoteh/$remotedb full db to $localh/$localdb SQL:"
echo ''
echo "run: 'echo \"ALTER DATABASE $localdb RENAME TO $localdb""_$date\" | psql -U postgres -h $localh'"
echo "run: 'echo \"CREATE DATABASE $localdb OWNER postgres TEMPLATE template1\" | psql -U postgres -h $localh'"
echo "run: 'psql -U postgres -h $localh $localdb < $remotefdb'" 
echo '--------------------------------------------------------------'
echo ''

echo "copy $localh/$localdb full db to $remoteh/$remotedb SQL:"
echo ''
echo "run: 'echo \"ALTER DATABASE $remotedb RENAME TO $remotedb""_$date\" | psql -U postgres -h $remoteh'"
echo "run: 'echo \"CREATE DATABASE $remotedb OWNER postgres TEMPLATE template1\" | psql -U postgres -h $remoteh'"
echo "run: 'psql -U postgres -h $remoteh $remotedb < $localfdb'" 
echo '--------------------------------------------------------------'
echo ''

