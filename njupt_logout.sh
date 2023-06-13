#!/bin/sh
# 关闭代理
unset no_proxy
unset all_proxy
unset http_proxy
unset https_proxy
unset ftp_proxy

ac_data=`cat ~/ac_data.txt`
DOMAIN="p.njupt.edu.cn"
LOGOUT_PORT=801
LOGOUT_PATH="/eportal/?c=ACSetting&a=Logout"

curl "http://${DOMAIN}:${LOGOUT_PORT}${LOGOUT_PATH}" \
  --data "${ac_data}"