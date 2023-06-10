# njupt_net

校园网drcom登录脚本，自动选定(可配置)网卡登录(防utun劫持)

具体原理可以去找drcom登录的相关教程，本质上就是发个http请求给认证服务器，需要提供的参数有：

+ 用户、服务商：`DDDDD`
+ 密码：`upass`
+ 路由器ip或name：`wlanacip`、`wlanacname`，服务器用于确认在哪接入校园网

未登录时，访问任意网址会返回认证html，里面有`wlanacip`、`wlanacname`。

登录参数是`c=ACSetting&a=Login`，登出参数则是`c=ACSetting&a=Logout`

上面的内容均是从登录网站上`F12`抓包确定的，有兴趣可以自己试试，用不了了也可以参照这个过程去修改脚本