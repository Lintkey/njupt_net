#!/bin/sh
#关闭代理
unset no_proxy
unset all_proxy
unset http_proxy
unset https_proxy
unset ftp_proxy

ac_data=`cat ac_data.txt`
host_name="p.njupt.edu.cn"

curl "http://${host_name}:801/eportal/?c=ACSetting&a=Logout"\
  --data "${ac_data}"