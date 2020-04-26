---
title: "SSL"
description: "openssl命令使用"
tags: [ "Liunx基础"]
categories: [ "Liunx", "Liunx" ]
keywords: [ "ssl", "openssl" ]
date: 2018-05-06
lastmod: 2019-12-23
---
### openssl简介
`openssl` 用于实现`http` `ftp` `smtp` 等一些应用层的加密传输,保证数据的安全性. http 协议等本身不具备加密解密的功能,  数据在明文在网上传输 , 对于一些保密性要求高的行业,(电商,网银支付的) ,以`https` 开头的就表示加密传输的 .

### 基本概念

#### 加密和解密种类

加密和解密大致有三种,每种又有很多不同的算法,互联网加密安全传输过程中这三种类型的加密算法都要,用到根据不同的特性实现不同的功能.

`对称加密`  :加密和解密使用同一个密钥 ,常用的由 `3DES` `AES` 等. 其特点有:

+ 加密和解密使用同一个密钥.效率高
+ 密钥过多,密钥分发,数据来源无法确认

`非对称加密` : 密钥是成对出现的 公钥 `public key` 和私钥 ` private key` ,公钥用于公开给所有人

私钥这是留给自己保存. 

加密的方法 :公钥和私钥都可以加密数据, 一种密钥加密的数据另一个配对的密钥才能解密. 由于私钥有不公开,一般由一人保存,所以有一下功能:

+ 用于数字签名, alice用私钥加密过的数据,用alice的公钥能解密,表示提供此数据是有alice本人加密的,从而判断了此数据的来源合法性
+ 用于对称密钥的交换, 非对称密钥长,加密速度极慢,通常不会用于互联网上数据加密传输, 通常做法是两台主机协商一个共同的对称密钥 ,然后相互用对方主机的公钥加密对称密钥.传输后验证对方的主机. 验证完成后,使用对称密钥传输数据

非对称加密的算法有 : `RSA`  `DSA`    ,通常rsa可以用来 加密,数字签名; dsa只能用户数字签名

`单向加密` :单向加密的功用是只能加密不能解密, 通常叫做提取数据特征码,指纹等 ,单向加密的特征有:

+ 无论源数据是什么,加密后的数据是固定长度
+ 数据的细小改变,特征码会发生巨大差别 (雪崩效应)
+ 无法解密

从单向加密的特征,通常用作验证数据的完整性,防止数据在传输过程中被篡改

单向加密的算法有 `md5` , `sha` 等 

`IKE`  Internet Key Exchange 互联网密钥交换 ,实现这个功能的算法叫 `DH` ,特点是: 双方主机协商产生密钥,只需要交换一些随机数,而密钥本身不需要在互联网上传输,增强了安全性

#### PKI

`PKI`  全称为 `Pbulic Key Infrastructure`  公钥基础设施 , 是实现公钥管理的一总规范和标准,实现这种规范管理的第三方管理机构,叫做 `CA` 

`CA` : Certificate Authority 证书鉴证机构

`RA` : Register Authority  证书注册机构, RA 负责接受企业的申请,统一提交CA 签署

`CRL` :Certificates Revoke List  证书吊销列表,证书会丢失,和过期. 列表内的表示不可用

`x509` :定义了证书的格式和认证协议的标准 .

#### 加密协议 

`SSL`  Secure Socket  Layer 安全的套接字层协议 

`TLS` Transaction Layer Secure  是ssl的增加版目前使用最多版本是 `tls 2.0` 

ssl/tls : 工作在应用层和tcp/ip协议之间, http封装过的数据包(文本格式)要由 ssl 验证后转为二进制格式,传给下一层.

ssl/tls 协议层很复杂,提供加密之前需要交换密钥,验证身份,最后加密数据.

注意 : ssl 会话的建立只能建立在ip地址上,这就意味这如果 web服务器,上建立了多个虚拟机主机,只有其中一个能实现加密功能

###  openssl 程序

centos系统中实现这种功能的软件包也叫 `openssl` 是 `SSL` 协议的一种开源的实现

`openssl` 程序由三个重要的组成部分:

- `libcrypto` :加密库,提供各种算法的函数. 各种程序大都需要这个库,是一个基本的组件
- `libssl` : 用于实现 TLS/SSL 协议 
- `opensll` :命令行的工具, 由很多子命令

### openssl 命令

#### 子命令

> `enc` 用于对称加密的 

openssl enc --help 查看帮助 或者 man enc  

```shell
openssl enc -e -aes-256-cfb -a -salt -in fstab -out fstab.cipher
```

`-e`  表示加密  `-aes-256-cfb`  指定算法  `-a`  指定以base64 文本格式输出  `-salt`  加盐  `-in`  指定要加密的文件  `-out`  表示加密后输出的文件

> `dgst` 用于单向加密

```shell
# 指定加密方式即可
openssl dgst -sha512 fstab
sha512sum fstab
```

拓展 : `MAC`  Message Authentication Code  消息认证码. 单向加密一种延伸应用 ,主要用于实现在网络通信中所有传输中保证所有传输数据完整性, 不关心其他的 . 这是一种算法

实现`MAC` 的应用有 `CBC-MAC`  `HMAC` 主要应用与集群环境中

> `passwd` 生成用户密码

```shell
openssl passwd -1 -salt 345hsa
```

`-1` 指定是用md5 加密 `-salt`  345hsa  ,后面跟随机数不超过8位

> `rand` 生成随机数

```shell
openssl rand -hex 8        
```

`-hex`  指定十六机制输出  输出为9个字节

> `genrsa` 生成私钥

```shell
openssl genrsa -out rsakey.private 2048
```

注意 : 要修改私钥的权限, 保证安全用 `enc` 对称加密

公钥是从私钥中提取出来的

```shell
openssl rsa -in rsakey.private -pubout   
```

注意: 公钥默认输出到终端, 保存请重定向,

### 搭建私有CA

步骤为 1: 生成rsa密钥对  2: 生成自签证书

配置文件路径 `/etc/pki/tls/openssl.cnf`   查看`[  CA_default ]`  配置段

必须备需要的文件和目录

```shell
private_key = private/cakey.pem        # 私钥的后缀和路路径
certificate = $dir/cacert.pem          # 证书的后缀和路径
serial      = $dir/serial              # 要创建序列号文件 echo 01
database    = $dir/index.txt           # 要创建索引目录
certs       = $dir/certs               # 准备证书目录
new_certs_dir   = $dir/newcerts        # 准备新签署证书目录
crl_dir     = $dir/crl                 # 准备证书吊销列表
```


> 1 生成私钥

```shell
(umask 077;openssl genrsa -out /etc/pki/CA/private/cakey.pem -des 2048)
```

`-des` 指定为私钥加密, `umask 007` 保证密钥生成是的权限最小

> 生成自签证书

```shell
cd /etc/pki/CA
openssl req -new -x509 -key private/cakey.pem -out cacert.pem -days 3650
```

注意: 使用的相对路径

> 查看证书以可读方式

```shell
openssl x509 -text -in cacert.pem       # 证书的x509的标准格式
```

> 生成证书颁发请求

```shell
(umask 077; openssl genrsa -out /tmp/http.key 2058)
openssl req -new -key /tmp/http.key -out /tmp/http.csr
```

注意: 

+ 每种服务都需要证书,以http为例 ,证书申请一般都是其他主机.
+ 默认国家,省,市,公司名称要也`CA` 的保持一致 . 而且 `server's name`  就是写此web服务器对外提供的域名
+ 证书颁发请求必须要以` .csr` 格式结尾

> `ca` 证书管理,签署证书颁发请求`.csr` 文件(Cerificate Signing Request)

```shell
openssl ca -in http.csr -out /etc/pki/CA/certs/http.crt -days 365
```

签好好发给请求方,他就可以使用了

### 快速生产自签名的证书用于 nginx https配置

```shell
openssl req -x509 -days 99999 -out www.zxslinuxtext.com.crt -keyout www.zxslinuxtext.com.key \
  -newkey rsa:2048 -nodes -sha256 \
  -subj '/CN=www.zxslinuxtext.com' -extensions EXT -config <( \
   printf "[dn]\nCN=www.zxslinuxtext.com\n[req]\ndistinguished_name = dn\n[EXT]\nsubjectAltName=DNS:www.zxslinuxtext.com\nkeyUsage=digitalSignature\nextendedKeyUsage=serverAuth")
# 替换命令中所有 www.zxslinuxtext.com 为实际域名
```

生产文件 `www.zxslinuxtext.com.crt` 为自签名的证书文件，`www.zxslinuxtext.com.key` 为私钥文件

nginx 启用 https 配置中指定文件路径即可使用

```shell
   # HTTPS server
    #
    server {
        listen       443 ssl;
        server_name  zxslinux.world;

        ssl_certificate      /PATH/zxslinux.world.crt;                           #  修改为证书实际路径             
        ssl_certificate_key  /PATH/TO/zxslinux.world.key;            #  修改为私钥实际路径

        ssl_session_cache    shared:SSL:1m;
        ssl_session_timeout  5m;

        ssl_ciphers  HIGH:!aNULL:!MD5;
        ssl_prefer_server_ciphers  on;

```

### 使用certbot 提供免费的https证书

官方文档 [https://letsencrypt.org/zh-cn/docs/](https://letsencrypt.org/zh-cn/docs/)

准备工作：
1. 准备一个域名
2. 将域名解析到你的服务器

步骤1: 下载工具脚本
```shell
wget https://dl.eff.org/certbot-auto -O /usr/local/bin/certbot-auto
chmod +x /usr/local/bin/certbot-auto
# certbot-auto 是一个python脚本
```

步骤2: 获取免费https证书

```shell
# 使用 certonly 子命令仅为了获取证书 -d 指定域名
certbot-auto certonly --standalone -d zxslinux.world   #执行此命令需要停止监听在 443端口的程序例如nginx

# 得到如下输出表示成功
IMPORTANT NOTES:
 - Congratulations! Your certificate and chain have been saved at:
   /etc/letsencrypt/live/zxslinux.world/fullchain.pem
   Your key file has been saved at:
   /etc/letsencrypt/live/zxslinux.world/privkey.pem
   Your cert will expire on 2020-07-25. To obtain a new or tweaked
   version of this certificate in the future, simply run certbot-auto
   again. To non-interactively renew *all* of your certificates, run
   "certbot-auto renew"
 - If you like Certbot, please consider supporting our work by:

   Donating to ISRG / Let's Encrypt:   https://letsencrypt.org/donate
   Donating to EFF:                    https://eff.org/donate-le
```

在nginx配置中指定证书和私钥的路径即可

步骤3: 配置定时任务更新证书

```shell
15 2 * */2 * certbot renew --pre-hook "/usr/local/nginx/sbin/nginx -s stop" --post-hook "/usr/local/nginx/sbin/nginx"
```

