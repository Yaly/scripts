#!/bin/bash
a=root
p='swddmysqlpwd309'


RQ=`date +%Y%m%d`

f="/mysqlback/$RQ"
if [ -d $f ]
then
  echo "success" > /dev/null
else
 mkdir -p $f

fi

mysql=`ls -l  /var/lib/mysql/ | awk '/^d/{print $NF}' | grep -Ev 'mysql|test'`
for i in $mysql
do
mysqldump -u $a -p$p $i > $f/$i.sql
cd $f
tar -cjvf $i.tar.bz2 $i.sql
rm -rf $i.sql
find /mysqlback/ -mtime +5 -exec rm -rf {} \;
done
#find /log/ -mtime +5 -exec rm -rf {} \;