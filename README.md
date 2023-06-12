# njupt_net

校园网drcom登录脚本，自动选定(可配置)网卡登录(防utun劫持)

# 原理

登录的过程本质上就是发个http请求给认证服务器，具体的参数解释可以在认证网站的html中可以看到，以njupt仙林校区为例：

```term
> curl p.njupt.edu.cn

...
sv=0;sv1=0;v6='http://[::]:9002/v6                                     ';myv6ip='                                       ';v4serip='10.10.244.11'   ;m46=0;v46ip='10.161.148.58'                          ;
vid=0   ;mip=010161148058;Gno=0000;vlanid="0"   ;AC="";                          ipm="0a0af40b";ss1="00e04c0bf19c";ss2="0000";ss3="0aa1943a";ss4="000000000000";ss5="10.161.148.58"  ;ss6="10.10.244.11"   ;timet=1686494842; 
osele=0;//1=不弹窗
domain='[::]';// ////////////////////////////////////////
...

...
//3.旁路参数
authexenable='0';//是否启用旁路扩展模式
authtype=1;//登录协议
authloginIP='';//登录IP
authloginport=801;//登录端口
authloginpath='/eportal/?c=ACSetting&a=Login';//登录路径
authloginparam=''; //登录参数
authuserfield='DDDDD';//账号节点
authpassfield='upass';//密码节点
terminalidentity=1;//终端识别标识 先配置成填写
authlogouttype=1;//注销协议
authlogoutIP='';//注销IP
authlogoutport=80;//注销端口
authlogoutpath='/eportal/?c=ACSetting&a=Logout&ver=1.0';//注销路径
authlogoutparam='';//注销参数
authlogoutpost='';//注销post参数
querydelay=0;//登录后延时查询网络状态
querytype=1;//状态查询协议
queryIP='';//状态查询IP	
queryport=80;//状态查询端口
querypost='';//状态查询post参数
querypath='/eportal/?c=ACSetting&a=Query';//状态查询路径
queryparam='';//状态查询参数
...
//4.运营商选择
carrier='{"yys":{"title":"服务类型","mode":"radiobutton","data":[{"id":"1","name":"校园用户","suffix":"@xyw"},{"id":"2","name":"校园电信","suffix":"@dx"},{"id":"3","name":"校园联通","suffix":"@lt"},{"id":"4","name":"校园其他","suffix":""}],"defaultID":"1"}}';//运营商选择
...
```

但是上面的内容仅供参考，因为那是未配置的默认参数

F12分析登录时的请求，可以看到登录POST的URL格式如下

```
http://10.10.244.11:801/eportal/?c=ACSetting&a=Login&...
http://${v4serip}:${authloginport}${authloginpath}&...
```

后面很多个参数中，未在html中有描述的有`wlanacip`、`wlanacname`，这个推测可知是路由器IP和唯一设备名

结合前面内容可以猜测，往指定链接POST并带上所需的参数即可完成登录/登出/查询

抓包分析到的URL带了一堆参数，但实际上起作用的仅有几个

+ `authloginpath`中的参数：指明要登录/登出/查询
+ `DDDDD`：账户(包含运营商)，格式为`,0,账户@运营商`，若使用校园网则是`,0,账户`
+ `upass`：密码
+ `wlanacip`、`wlanacname`：路由器身份信息，这两个仅需传一个即可

剩下的问题就是获取`wlanacip`、`wlanacname`，这个在访问任意网页时弹出的登录跳转html中有，未登录时`curl baidu.com`即可看到：

```html
<html>
<head>
<script type="text/javascript">location.href="http://10.10.244.11/a79.htm?wlanuserip=10.161.148.58&wlanacip=10.255.252.150&wlanacname=XL-BRAS-SR8806-X"</script>
</head>
<body>
Authentication is required. Click <a href="http://10.10.244.11/a79.htm?wlanuserip=10.161.148.58&wlanacip=10.255.252.150&wlanacname=XL-BRAS-SR8806-X">here</a> to open the authentication page.
</body>
</html>
```

结合前面内容，就可得到登录的`curl`命令：

```sh
# 考虑到这几个参数在校内不变，因此也可以直接使用常量替代
# curl "http://${v4serip}:${authloginport}${authloginpath}"\
curl "http://10.10.144.11:801/eportal/?c=ACSetting?a=Login"\
      --data-urlencode "DDDDD=,0,${USER}${ISP}"\
      --data-urlencode "upass=${PWD}"\
      --data "wlanacname=${an_name}"
# 宿舍路由器等固定应用场所，也可以获取`ac_name`后替换，即可实现一行命令登录
```