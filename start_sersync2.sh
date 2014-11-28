=========================================== sersync2 启动脚本 ===========================================
#!/bin/bash

if [ ! -f /usr/local/sersync/log/sersync2.log ];then
touch /usr/local/sersync/log/sersync2.log
fi

echo "Starting sersync2" >>/usr/local/sersync/log/sersync2.log
xmlfile=`ls /usr/local/sersync/conf/ |grep 'xml$'`
for xml in $xmlfile 
do
echo >> /usr/local/sersync/log/sersync2.log
date >> /usr/local/sersync/log/sersync2.log
echo "Starting $xml" >> /usr/local/sersync/log/sersync2.log
sersync2 -d -o /usr/local/sersync/conf/$xml >> /usr/local/sersync/log/sersync2.log
done