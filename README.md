# njupt_net

校园网drcom登录脚本，如clash开启utun，需添加规则`- 'IP-CIDR,1.1.1.1/32,DIRECT,no-resolve'`

# 复用相关问题

## 如何应用到其他DrCOM认证服务器

看脚本中的扩展参数，修改对应参数至服务器要求。具体获取方法请参照下面内容

## 原理及如何确定参数

登录的过程本质上就是发个http请求给认证服务器，如何请求可通过抓包分析(浏览器F12开发工具，网络开启不清除日志)，寻找带`login`字眼的请求

最新的`4.0`(垃圾drcom居然在假期更新了??)的登录端口、path和所需参数如下

```sh
HTTP_PORT=801
HTTPS_PORT=802
LOGIN_PATH="/eportal/portal/login?callback=drcom"           # callback控制请求返回值的前缀
# CHECK_PATH=                                                 # 新版把check砍了
STATUS_PATH="/eportal/portal/online_list?callback=drcom"    # 改用这个可查询网络使用信息

# 下面是url参数
"user_account=${USER}${ISP}"  # ISP为`@ + 运营商代号`，例如南京电信 `@njxy`，校园网留空，这个看学校情况
"user_password=${PASSWORD}"
```

旧版的如下

```sh
HTTP_PORT=801
HTTPS_PORT=802
LOGIN_PATH="/eportal/?c=ACSetting&a=Login"
CHECK_PATH="/eportal/?c=ACSetting&a=checkScanIP"

# 下面是url参数
"DDDDD=${USER}${ISP}"
"upass=${PASSWORD}"
```

需要注意的是，账户、密码放入参数需要URL转码，linux下可使用`jq`指令实现

## 如何避开utun解析

两种方案：

1. 识别网卡，使用上网卡`curl`登录(防止utun影响解析)，这个没法移植到win(有的话可以提issue)
2. 不识别网卡，添加规则让`1.1.1.1/32`直连(`DIRECT`)且不二次解析(`no-resolve`)，这样直接`curl`登录不受utun解析影响

方案一需要识别网卡，比较麻烦且不稳定，而且检测连接需要尝试`curl 1.1.1.1`直至失败，等待时间久

方案二`curl 1.1.1.1`不受影响，可以及时响应，但无法应对以下情况：如果响应的跳转链接网址是域名而非裸IP，utun依然会影响登录网址的解析