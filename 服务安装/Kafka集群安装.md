## Kafka集群安装 

1.官网下载kafka、zookeeper，版本对应一直



2.解压zookeeper，进入conf

```
mv zoo_sample.cfg zoo.cfg
```

3.配置zoo.cfg

```
tickTime=2000
initLimit=10
syncLimit=5
dataDir=/opt/zookeeper/zkdata
clientPort=12181
//此处的IP就是你所操作的三台虚拟机的IP地址，每台虚拟机的zoo.cfg中都需要填入这三个地址。第一个端口是master和slave之间的通信端口，默认是2888，第二个端口是leader选举的端口，集群刚启动的时候选举或者leader挂掉之后进行新的选举的端口默认是3888
//所在的主机ip写成0.0.0.0
server.1=0.0.0.0:12888:13888 
server.2=192.168.172.11:12888:13888
server.3=192.168.172.12:12888:13888
//server.1 这个1是服务器的标识也可以是其他的数字， 表示这个是第几号服务器，用来标识服务器，这个标识要写到dataDir目录下面myid文件里
```

4.在zkdata目录下放置myid文件：(上面zoo.cfg中的dataDir)  myid指明自己的id，对应上面zoo.cfg中server.后的数字，第一台的内容为1，第二台的内容为2，第二台的内容为3

5.启动zookeeper

```
./zkServer.sh start
```

6.查看zookeeper状态

```
./zkServer.sh status
```

**---------------------------搭建集群遇到的问题--------------------------------**

（1）须关闭防火墙，不然不能启动成功

```
# service iptables stop
# chkconfig iptables off
```

（2）拒绝连接

```
启动报错：拒绝连接，需开放所有zookeeper端口
# /sbin/iptables -I INPUT -p tcp --dport 12181 -j ACCEPT
# /sbin/iptables -I INPUT -p tcp --dport 12888 -j ACCEPT
# /sbin/iptables -I INPUT -p tcp --dport 13888 -j ACCEPT
```

7.解压kafka，进去config编辑server.properties

```
//这是这台虚拟机上的值，在另外两台虚拟机上应该是2或者3，这个值是唯一的，每台虚拟机或者叫服务器不能相同
broker.id=1
//设置本机IP和端口:这个IP地址也是与本机相关的，每台服务器上设置为自己的IP地址,端口号默认是9092，可以自己设置其他的
listeners=PLAINTEXT://192.168.172.10:9092
//如果想被外网访问
advertised.listeners=PLAINTEXT://10.211.55.20:9092
//日志文件地址
log.dirs=/opt/kafka
//在og.retention.hours=168下面新增下面三项
message.max.byte=5242880
default.replication.factor=2
replica.fetch.max.bytes=5242880
//指定日志位置
log.dirs=/data/kafka-logs
//设置日志删除
log.retention.hours=120
log.cleanup.polict=delete
log.segment.delete.delay.ms=1000
log.cleanup.interval.mins=1
log.retention.check.interval.ms=1000
//设置zookeeper的连接端口，zookeeper.connect可以设置多个值,多个值之间用逗号分隔
zookeeper.connect=10.211.55.11:2181,10.211.55.19:2181,10.211.55.20:2181
```

8.启动kafka集群

```
cd /usr/local/kafka_2.12-2.1.1/bin/
./kafka-server-start.sh -daemon ../config/server.properties
```

