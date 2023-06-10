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

# 自动选择网卡
# 在此可配置需要过滤的项(例如过滤cfw的utun网卡：grep -v utun)
con_status=`ip -f inet a|grep inet|grep -v "127.0.0.1"|grep -v utun`
# 以最后一个有ipv4连接的网卡作为网卡(我的有线网卡外置，记录靠后，这样可优先使用有线网卡)
interface=`echo ${con_status}|awk 'END{print $NF}'`

# 未登陆情况下
#   使用utun时，DNS解析失败，获得空串
#   不使用utun时，过滤后获得空串
curl_test=`curl "https://bing.com" -s|grep "www.bing.com"`  # baidu限速，因此换bing
if [ -n "${curl_test}" ]; then
  echo "Connected!"
else
  # 获取有(user_ip、ac_ip、ac_name)参数以及host_name的登录url
  login_url=`curl --interface $interface '1.1.1.1' -sS|grep '<a'|grep -Eo 'http[^"]*'`
  echo ${login_url}
  if [ -n "${login_url}" ]; then
    # 从login_url截取host_name，即认证服务器网址
    # 学校的认证服务器一般在学校内网，所以只要不重启，host_name大概率是固定的裸内网ipv4
    # 但是考虑到适用性，还是从login_url中截取
    host_name=`echo ${login_url}|grep -Eo "/[^/?]+/"|grep -Eo "[^/]*"`  # host_name="10.10.244.11"
    # host_name="p.njupt.edu.cn" # 这个能解析到服务器，但是仅能用于登出(应该

    # 登录需要ac_name、ac_ip中任意一个
    ac_data=`echo ${login_url}|grep -Eo "wlanacname=[^&]*"`
    echo ${ac_data} > ac_data.txt # 供njupt_logout.sh使用

    # 参考drcom连接教程修改而来
    # 需要确认的有：请求地址、登录参数、用户、密码、路由器信息
    curl --interface $interface \
    "http://${host_name}:801/eportal/?c=ACSetting&a=Login" \
      --data-urlencode "DDDDD=,0,${USER}${ISP}"\
      --data-urlencode "upass=${PWD}"\
      --data "${ac_data}"
  fi

  curl_test=`curl "https://bing.com" -s|grep "www.bing.com"`
  if [ -n "${curl_test}" ]; then
    echo "Successful connection"
  else
    echo "Connection error"
  fi
fi