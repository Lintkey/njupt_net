#!/bin/sh
#关闭代理
unset no_proxy
unset all_proxy
unset http_proxy
unset https_proxy
unset ftp_proxy

# 默认账户信息
# 用户名
USER=""
# 密码
PWD=""
# 服务商：电信 njxy; 移动 cmcc; 校园网留空
ISP="njxy"

# 从命令行参数获取账户信息
if [ -n "$1" ]; then
  USER="$1"
  if [ -n "$2" ]; then
    PWD="$2"
    if [ -n "$3" ]; then
      ISP="$3"
    fi
  fi
fi

if [ -n $ISP ]; then
  ISP="@$ISP"
fi

curl_test=`curl '1.1.1.1' -sS`
if [ -n "${curl_test}" ]; then
  # 未登录时访问任意网址会得到一个登录跳转的html
  # 登录跳转链接里有user_ip、ac_ip、ac_name参数
  login_url=`echo ${curl_test}|grep '<a'|grep -Eo 'http[^"]*'|awk 'NR==1{print}'`
  echo "login_url=${login_url}"
  if [ -n "${login_url}" ]; then
    # 考虑到适用性，还是从login_url中截取host_name
    host_name=`echo ${login_url}|grep -Eo "/[^/?]+/"|grep -Eo "[^/]*"`
    # host_name="p.njupt.edu.cn" # 这个能解析到服务器，但是开了utun会影响解析
    echo "server_ip=${host_name}"

    # 登录需要ac_name、ac_ip中任意一个
    ac_data=`echo ${login_url}|grep -Eo "wlanacname=[^&]*"`
    echo ${ac_data} > ~/ac_data.txt # 供njupt_logout.sh使用

    # 登录需要确认的有：请求地址、登录参数、用户、密码、路由器信息
    curl "http://${host_name}:801/eportal/?c=ACSetting&a=Login" \
      --data-urlencode "DDDDD=,0,${USER}${ISP}" \
      --data-urlencode "upass=${PWD}" \
      --data "${ac_data}"
  fi

  curl_test=`curl "4.ipw.cn" -s|awk 'NR==1{print}'|grep -Eo "[0-9.]"`
  if [ -n "${curl_test}" ]; then
    echo "Login successfully."
  else
    echo "Login failed!"
  fi
else
  echo "Connected!"
fi