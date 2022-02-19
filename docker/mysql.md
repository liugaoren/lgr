### MYSQL部署

#### 1. 搜索mysql镜像

```
docker search mysql
```

#### 2.拉取mysql镜像

```
docker pull mysql:5.6
```

#### 3. 创建容器，设置端口映射、目录映射

```
mkdir ~/mysql
cd ~/mysql
```

```
docker run -id \
-p 3307:3306 \
--name=c_mysql \
-v $PWD/conf:/etc/mysql/conf.d \
-v $PWD/logs:/logs \
-v $PWD/data:/var/lib/mysql \
-e MYSQL_ROOT_PASSWORD=123456 \
mysql:5.6
```

\- 参数说明：

  \- **-p 3307:3306**：将容器的 3306 端口映射到宿主机的 3307 端口。

  \- **-v $PWD/conf:/etc/mysql/conf.d**：将主机当前目录下的 conf/my.cnf 挂载到容器的 /etc/mysql/my.cnf。配置目录

  \- **-v $PWD/logs:/logs**：将主机当前目录下的 logs 目录挂载到容器的 /logs。日志目录

  \- **-v $PWD/data:/var/lib/mysql** ：将主机当前目录下的data目录挂载到容器的 /var/lib/mysql 。数据目录

  \- **-e MYSQL_ROOT_PASSWORD=123456：**初始化 root 用户的密码。

#### 4.进入容器，操作mysql

```
docker exec –it c_mysql /bin/bash
```



### mongo部署

```
docker pull mongo:latest
```

```
docker images
```

```
docker run -itd --name mongo -p 27017:27017 mongo --auth
```

```
docker exec -it mongo mongo admin
```

创建一个名为 admin，密码为 123456 的用户

```
db.createUser({ user:'admin',pwd:'123456',roles:[ { role:'userAdminAnyDatabase', db: 'admin'},"readWriteAnyDatabase"]});
```

尝试使用上面创建的用户信息进行连接

```
db.auth('admin', '123456')
```



### rabbitMQ部署

#### 1.在虚拟机中启动RabbitMQ

```
docker run -id --name=tensquare_rabbit -p 5671:5671 -p 5672:5672-p 4369:4369 -p 15672:15672 -p 25672:25672 rabbitmq:management
```

#### 2.访问地址：http://192.168.200.128:15672

登录账号： guest

登录密码： guest