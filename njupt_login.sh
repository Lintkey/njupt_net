#!/bin/sh
#关闭代理
unset no_proxy
unset all_proxy
unset http_proxy
unset https_proxy
unset ftp_proxy

# 默认账户信息
USER="" # 用户名
PWD="" # 密码
ISP="" # 服务商：电信 njxy; 移动 cmcc; 校园网留空

# 扩展参数
DOMAIN="p.njupt.edu.cn"
LOGIN_PORT=801
LOGIN_PATH="/eportal/?c=ACSetting&a=Login"
CHECK_PORT=801
CHECK_PATH="/eportal/?c=ACSetting&a=checkScanIP"

# LOGIN_URL="${DOMAIN}:${LOGIN_PORT}${LOGIN_PATH}"
CHECK_URL="${DOMAIN}:${CHECK_PORT}${CHECK_PATH}"

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

# 1.1.1.1 正常会301 move/连接失败
curl_test=`curl "1.1.1.1" -s|grep Authentication`
if [ -n "${curl_test}" ]; then
  # 未登录时访问任意网址会得到一个登录跳转的html
  # 登录跳转链接里有user_ip、ac_ip、ac_name参数
  info_url=`curl "1.1.1.1" -sS|grep '<a'|grep -m 1 -Eo 'http[^"]*'`
  echo ${info_url}
  if [ -n "${info_url}" ]; then
    # 获取认证服务器IP，这一步是防止utun影响域名解析，干脆直接使用IP
    DOMAIN=`echo ${info_url}|grep -Eo "/[^/?]+/"|grep -Eo "[^/]*"`

    # 登录需要ac_name、ac_ip中任意一个
    ac_data=`echo ${info_url}|grep -Eo "wlanacname=[^&]*"`
    echo ${ac_data} > ~/ac_data.txt # 供njupt_logout.sh使用

    # 登录需要确认的有：请求地址、登录参数、用户、密码、路由器信息
    curl "${DOMAIN}:${LOGIN_PORT}${LOGIN_PATH}" \
      --data-urlencode "DDDDD=,0,${USER}${ISP}" \
      --data-urlencode "upass=${PWD}" \
      --data "${ac_data}"
  fi

  sleep 0.1
  curl_test=`curl "${CHECK_URL}" -sS`
  echo ${curl_test}
else
  echo "Connected!"
  curl_test=`curl "${CHECK_URL}" -s`
  if [ -n "${curl_test}" ]; then
    echo ${curl_test}
  fi
fi