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

echo "enter root pass"
read pass

sqlq="select schema_name from information_schema.SCHEMATA where SCHEMA_NAME not in ('mysql', 'information_schema', 'performance_schema') ORDER BY schema_name ASC"

#mysql -u root -p$pass -B -e "$sqlq" -s --skip-column-names
#exit

service mysql restart

echo "all databases to optimization"
for I in $(mysql -u root -p$pass -B -e "$sqlq" -s --skip-column-names);
do
  if ( array_contains $I ignored ) 
  then
    echo "-$I (ignored by -i parameter)"
  else
    if [[ "$I" < "$startfrom" ]]
      then
    echo "-$I (ignored by -s parameter)"
      else
	mysqlcheck -u root --password=$pass --auto-repair --check $I
#	mysqlcheck -u root --password=$pass --auto-repair --check --optimize  $I
      fi
  fi
#  sleep 3
#  service mysql restart
  sleep 1
done
