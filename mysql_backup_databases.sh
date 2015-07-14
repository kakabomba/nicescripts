#!/bin/bash

de='mysql,information_schema,performance_schema'
dd='.'
du=`whoami`
da='--routines'
dls='--single-transaction --quick --lock-tables=false'
df=''
dt=''
#mysqldump -u root -p$pass --routines $I | gzip > "$dest$I-$date.sql.gz"  # offlineserver all data

e="$de"
d="$dd"
a="$da"
u="$du"
from="$df"
to="$dt"
i=''

array_contains () { 
    local array="$2[@]"
    local seeking=$1
    local in=1
    for element in "${!array}"; do
        if [[ $element == $seeking ]]; then
            in=0
            break
        fi
    done
    return $in
}

function ign () {
    if [[ ${#e[@]} > 0 ]] && ( array_contains $1 e ); then
      ret="excluded by -e"
      return 1
    fi
    if [[ ${#i[@]} > 0 ]] && !( array_contains $1 i ); then
      ret="excluded by not in -i"
      return 1
    fi
    if [[ "$from" != "" && "$1" < "$from" ]]; then
      ret="excluded by < -f"
      return 1
    fi
    if [[ "$to" != "" && "$1" > "$to" ]]; then
      ret="excluded by > -t"
      return 1
    fi
    ret=""
    return 0
}



usage () {
    echo "dump mysql databases in separate files"
    echo ''
    echo "$0 -d dir=$dd -u user="'`'"whoami"'`'" -p pass -i inc -e exc=$de -f from -t to -a args=$da -l"
    echo ''
    echo '         all arguments are optional'
    echo ''
    echo "        -d[destination] destination dir"
    echo "        -u[user]"
    echo "        -p[password]"
    echo "        -i[nclude] include databases, comma separated names"
    echo "        -e[xclude] exclude databases, comma separated names"
    echo "        -f[rom] start from database (inclusive)"
    echo "        -t[o] stop at database (inclusive)"
    echo "        -a[rguments] additional mysql arguments"
    echo "        -l[ive] work with live mysql server. (don't block other connected clients. prepended '$dls' to mysql arguments -a)"
    echo ''

}

while [[ $# > 0 ]]
do
key="$1"
case $key in
    -p|--password)
    p="$2"
    shift
    ;;
    -h|--help)
    usage
    exit
    ;;
    -e|--exclude)
    e="$2"
    shift
    ;;
    -i|--include)
    i="$2"
    shift
    ;;
    -f|--from)
    from="$2"
    shift
    ;;
    -t|--to)
    to="$2"
    shift
    ;;
    -d|--destination)
    d="$2"
    shift
    ;;
    -a|--arguments)
    a="$2"
    shift
    ;;
    -l|--live)
    l="$dls"
    ;;
    -u|--user)
    u="$2"
    shift
    ;;
    *)
    usage
    exit
    ;;
esac
shift
done

IFS=',' read -a i <<< "$i"
IFS=',' read -a e <<< "$e"

#echo -e ${#ee[@]}
#exit

sqlq="SELECT schema_name FROM information_schema.SCHEMATA ORDER BY schema_name ASC"

#if [[ "$e" != "" || "$i" != "" ]]; then
#  sqlq="$sqlq WHERE '1' "
#  if [[ "$i" != "" ]]; then
#    i=`echo "$i" | sed "s/\s//g; s/,/','/g"`
#    sqlq="$sqlq AND SCHEMA_NAME IN ('$i')"
#  fi
#  if [[ "$e" != "" ]]; then
#    e=`echo "$e" | sed "s/\s//g; s/,/','/g"`
#    sqlq="$sqlq AND SCHEMA_NAME NOT IN ('$e')"
#  fi
#fi

if [[ "$p" != "" ]]; then
    p="-p$p"
fi


echo "databases to dump:"
for I in $(mysql -u $u $p -B -e "$sqlq" -s --skip-column-names);
do
  ign $I
  if [[ "$ret" != ""  ]]
        then
            echo "-$I ($ret)"
        else
    	    echo "+$I"
  fi
done

echo "Mysql dump command: mysqldump -u$u $p $l $a <database> | gzip > $d/<database>-<date>.sql.gz)"

for I in $(mysql -u $u $p -B -e "$sqlq" -s --skip-column-names);
do
  ign $I
  if [[ "$ret" != ""  ]]
        then
            echo "-$I ($ret)"
        else
	    date=`date "+%Y_%m_%d_%H_%M_%S"`
	    echo "+$I > $d/$I-$date.sql.gz"
	    mysqldump -u$u $p $l $a $I | gzip > "$d/$I-$date.sql.gz"
  fi
done


exit

echo "Mysql dump command: mysqldump -u$u $p $l $a <database> | gzip > $d/<database>-<date>.sql.gz)"

for I in $(mysql -u $u $p -B -e "$sqlq" -s --skip-column-names);
do
  sleep 1
  if ( array_contains $I i ) 
  then
    echo "-$I (ignored by -i parameter)"
  else
    if [[ "$from" != "" && "$I" < "$from" ]]
      then
        echo "-$I (ignored by -f parameter)"
      else
        if [[ "$to" != "" &&  "$I" > "$to" ]]
          then
            echo "-$I (ignored by -t parameter)"
          else
    	    date=`date "+%Y_%m_%d_%H_%M_%S"`
	    echo "+$I > $d/$I-$date.sql.gz"
	    mysqldump -u$u $p $l $a $I | gzip > "$d/$I-$date.sql.gz"
        fi
      fi
  fi
done

