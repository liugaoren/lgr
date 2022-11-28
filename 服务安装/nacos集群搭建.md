### nacos集群搭建

下载地址：https://github.com/alibaba/nacos/releases/tag/1.4.1



将conf文件夹下面的nacos-mysql.sql脚本在mysql中执行。

修改/conf文件夹下面的application.properties文件，增加mysql持久化配置。

```
spring.datasource.platform=mysql

db.num=1
db.url.0=jdbc:mysql://127.0.0.1:3306/nacos_config?useUnicode=true&characterEncoding=utf-8&useSSL=false
db.user=root
db.password=123456
```

在nacos文件夹中修改/conf文件夹下面的cluster.conf，初始是没有的，只有个cluster.conf.example

增加如下配置：

```
192.168.8.128:8847
192.168.8.129:8847
192.168.8.130:8847
```

启动：

```
startup.sh
```



##  使用nginx做负载均衡

修改nginx的配置文件

```
        upstream cluster{
             server 192.168.8.128:8848;
             server 192.168.8.129:8848;
             server 192.168.8.130:8848;
        }
        server {
            #server全局块
            listen       9999;
            server_name  192.169.8.128;
            #location块
            location / {
                proxy_pass http://cluster;
            }
        }
```

