#!/bin/bash 
HTTP_CONF_DIR=/etc/httpd/conf.d  //创建变量指向虚拟主机配置目录 
CONF_FILE_NAME=virt_host.conf  //定义所有虚拟主机配置文件名 
HTTP_SITE_DIR=/var/www  //定义虚拟主机网站主目录位置 
//以上路径及名称都可以根据需求任意改动 
input_fun()  //定义函数input_fun，实现输入空信息再次读取 
{ 
        OUTPUT_VAR=$1  //这里$1其实就是Input Host ip [192.168.0.1]:或Input Virtual Host Name [www.example.com]: 
        INPUT_VAR=""  //定义变量INPUT_VAR起始值为空 
                while [ -z $INPUT_VAR ];do  //判断变量INPUT_VAR是否为空 
                        read -p "$OUTPUT_VAR" INPUT_VAR //进入交互继续输入IP地址，直到输出内容后退出循环 
                done 
        echo $INPUT_VAR  
} 
IPADDR=$( input_fun "Input Host ip [192.168.0.1]: ") //定义变量IPADDR，交互式输入的IP地址为值 
WEB_HOST_NAME=$(input_fun "Input Virtual Host Name [www.example.com]: ") //定义变量WEB_HOST_NAME，交互式输入的域名为值 
[ ! -d $HTTP_SITE_DIR/$WEB_HOST_NAME ] && mkdir -p $HTTP_SITE_DIR/$WEB_HOST_NAME  //判断虚拟主机目录是否存在，不存在创建虚拟主机目录 
chown apache. $HTTP_SITE_DIR/$WEB_HOST_NAME && chmod 755 $HTTP_SITE_DIR/$WEB_HOST_NAME //修改虚拟主机目录的所有权和访问权限 
if [ -f $HTTP_CONF_DIR/$CONF_FILE_NAME ];then  //判断虚拟主机配置文件是否存在 
        NameVir_key=$(grep NameVirtualHost $HTTP_CONF_DIR/$CONF_FILE_NAME) //如果存在，过滤里面的NameVirtualHost字段复制给变量NameVir_key 
fi 
if [ -z "$NameVir_key" ];then  //查看NameVir_key是否为空值 
        echo "NameVirtualHost $IPADDR:80" >$HTTP_CONF_DIR/$CONF_FILE_NAME //如果为空，创建虚拟主机配置文件，并写入NameVirtualHost $IPADDR:80 
fi 
cat >> $HTTP_CONF_DIR/$CONF_FILE_NAME << ENDF  //写虚拟主机配置文件信息追加到配置文件中 
<VirtualHost $IPADDR:80> 
        ServerAdmin webmaster@$WEB_HOST_NAME 
        DocumentRoot $HTTP_SITE_DIR/$WEB_HOST_NAME 
        ServerName $WEB_HOST_NAME 
        ErrorLog logs/$WEB_HOST_NAME-error_log 
        CustomLog logs/$WEB_HOST_NAME-access_loh common 
</VirtualHost> 
ENDF 
/etc/init.d/httpd restart  //重启httpd服务 