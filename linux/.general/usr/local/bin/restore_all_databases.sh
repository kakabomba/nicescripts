#!/bin/bash

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

ignored=()
startfrom=""
dest="./"

while getopts "h?i:s:d:" opt; do
  case $opt in
      i) IFS=',' read -a ignored <<< "$OPTARG"
    ;;
      d) dest="$OPTARG"
      ;;
      s) startfrom="$OPTARG"
      ;;
      h) echo " -i database_to_ignore,and_this_db_ignore_too -s start_from_database_in_alpha_order -d destination_dir" >&2
  ;;
esac
done


sqlq="select schema_name from information_schema.SCHEMATA where SCHEMA_NAME not in ('mysql', 'information_schema', 'performance_schema') ORDER BY schema_name ASC"

#mysql -u root -p$pass -B -e "$sqlq" -s --skip-column-names
#exit

echo "all databases to restore:"
for I in $(/bin/ls $dest);
do
  J=`echo $I | sed -es"/-[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9].sql.gz//"`
  if ( array_contains $J ignored ) 
  then
    echo "-$I (ignored by -i parameter)"
  else
    if [[ "$J" < "$startfrom" ]]
      then
    echo "-$I (ignored by -s parameter)"
      else
              echo "+$I"
      fi
  fi
done

echo "enter root pass to proceed"
read pass


for I in $(/bin/ls $dest);
do
  J=`echo $I | sed -es"/-[0-9][0-9][0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9]_[0-9][0-9].sql.gz//"`
  if ( array_contains $J ignored ) 
  then
    echo "-$I (ignored by -i parameter)"
  else
    if [[ "$J" < "$startfrom" ]]
      then
    echo "-$I (ignored by -s parameter)"
      else
        mysql -u root -p$pass -B -e "CREATE DATABASE $J"
	sleep 1
	echo "$dest/$I"
	gzip -d "$dest/$I" -c | mysql -u root -p$pass $J
	sleep 1
      fi
  fi
done
