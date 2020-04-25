#### es 集群搭建

踩坑记录

1. 问题现象： es集群无法启动报如下错误

```shell
[2020-03-29T00:16:55,802][ERROR][o.e.b.Bootstrap          ] [node_192.168.124.221] node validation exception
[1] bootstrap checks failed
[1]: memory locking requested for elasticsearch process but memory is not locked
```

原因:  大概意思是配置了内存锁(不使用swap) 但是操作系统中没有禁用swap

解决:  在 elasticsearch.service systemd服务配置文件中添加 `LimitMEMLOCK=infinity`