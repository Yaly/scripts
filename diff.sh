#!/bin/bash
for i  in  `cat /root/source1.txt`
do
	cat /root/end3.txt | grep $i 
	if [ $? !=0 ];then
		echo $i >> /root/end4.txt
	fi
done