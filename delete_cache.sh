#!/bin/bash

if [ -z $1 ]; then
        exit 1
else
	for remoteaddr in `cat /opt/remoteaddress.txt`
	do	
				ssh -p 65534 root@${remoteaddr} /bin/bash /opt/test2.sh > /dev/null &
	done

fi
exit 0




for project in `cat /opt/project.txt`
do
	rm -rf /webdata/$project/tmp/cache/*$1*.html
done






#!/bin/bash

if [ -z $1 ]; then
	echo "here is nothing! Please input something!"
else
	echo `hostname`
	echo $1
fi


rkyydd.1802828.com
183.57.39.179
122.13.225.179
FTP用户名：rkyydd
FTP密码：g#f/z_b+TXUP


for i in `ls -alru /var/www/html/img/ |head -n 100 |awk '{print $9}'`
do
	cp -rf /var/www/html/img/$i /root/img
done




rjh.shgao.cn

