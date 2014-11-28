#!/bin/bash
# To find the files which calling httpd query to the 232 server
PID=`netstat -anputl |grep 3306 |grep httpd | head -n 1 |awk '{print $7}' |awk -F'/' '{print $1}'`
printf "%d" "'$PID"
echo $PID
if [  $PID = "i" ]; then
        echo "There is nothing"
else
        ps -efL |grep "$PID"
fi