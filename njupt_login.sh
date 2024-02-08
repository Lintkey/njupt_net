#!/bin/sh
# 关闭代理
unset no_proxy
unset all_proxy
unset http_proxy
unset https_proxy

# 默认账户信息
USER="" # 用户名
PWD="" # 密码
ISP="" # 服务商：电信 njxy; 移动 cmcc; 校园网留空

# 扩展参数
# DOMAIN="p.njupt.edu.cn" # 开了UTUN就不要设置这个
HTTP_PORT=801
HTTPS_PORT=802
LOGIN_PATH="/eportal/portal/login?callback=drcom"

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

ACCOUNT=`jq -rn --arg x ",0,${USER}${ISP}" '$x|@uri'`
PASSWORD=`jq -rn --arg x "${PWD}" '$x|@uri'`

# 1.1.1.1 正常会301 move/连接失败
curl_test=`curl "1.1.1.1" -s|grep Authentication`
if [ -n "${curl_test}" ]; then
  # 未登录时访问任意网址会得到一个登录跳转的html
  if [ ! -n "${DOMAIN}" ]; then
    login_url=`curl "1.1.1.1" -sS|grep '<a'|grep -m 1 -Eo 'http[^"]*'`
    DOMAIN=`echo ${login_url}|grep -Eo "/[^/?]+/"|grep -Eo "[^/]*"`
    echo ${login_url}
  fi

  curl "${DOMAIN}:${HTTP_PORT}${LOGIN_PATH}&user_account=${ACCOUNT}&user_password=${PASSWORD}"
  echo
else
  echo "Connected!"
fi
curl "https://p.njupt.edu.cn:802/eportal/portal/online_list?callback=drcom"
