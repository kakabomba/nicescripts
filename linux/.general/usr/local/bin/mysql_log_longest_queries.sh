tail -f /var/log/mysql/mysql-slow.log|  awk '/User.Host/ {pri=100}
pri==100 && /Query_time: [1-9]/ {print prev; pri=99}
pri==99 {print}
{prev=$0}'
