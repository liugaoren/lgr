### mysql主从配置

#### 1.配置my.cnf

主库

```
server-id=1
# 启用二进制日志
log-bin=mysql-bin
# 设置不要复制的数据库(可设置多个)
binlog-ignore-db=sys
binlog-ignore-db=mysql
binlog-ignore-db=information_schema
binlog-ignore-db=performance_schema
# 设置需要复制的数据库(可设置多个)
binlog-do-db=test
binlog-do-db=student
# 设置logbin格式
binlog_format=STATEMENT
#遇到错误跳过
slave-skip-errors=all
```

从库

```
# 主从复制-从机配置
#限制普通用户只读（拥有super失效,mysql8.0.18后拥有CONNECTION_ADMIN不起作用）
read_only = 1
#限制拥有SUPER权限的用户只读
super_read_only = 1
# 从服务器唯一ID
server-id=2
# 启用中继日志
relay-log = /var/log/mysql/mysql-relay-bin.log
relay-log-index = /var/log/mysql/mysql-relay-bin.index
#遇到错误跳过
slave-skip-errors=all
```

#### 2.先同步主库原有的数据

```
#锁定主服务器的数据库，以确保在进行数据导出时没有新的写操作：
FLUSH TABLES WITH READ LOCK;

#在锁定数据库后，获取当前的二进制日志文件和位置：
SHOW MASTER STATUS;

#使用mysqldump导出主服务器的数据库数据
mysqldump -u root -p --all-databases --master-data=2 --single-transaction --quick --lock-tables=false > dump.sql

--master-data=2选项会在导出的SQL文件中包含CHANGE MASTER TO语句，这将记录主服务器的二进制日志文件名和位置。
--single-transaction选项会确保数据的一致性。
--quick选项会提升导出速度。
--lock-tables=false选项会确保在导出过程中不会再次锁定表。

#解锁主服务器数据库
UNLOCK TABLES;

#在从服务器上导入数据
mysql -u root -p < dump.sql

```



#### 3.创建从库用户，进行同步

```
# 登录
mysql -uroot -p

# 创建用户
create user 'slave'@'%' identified with mysql_native_password by '123456';

# 授权
grant replication slave on *.* to 'slave'@'%';

# 刷新权限
flush privileges;
```

- 主数据库查询服务ID及Master状态

```
# 登录
mysql -uroot -p

# 查询server_id是否可配置文件中一致
show variables like 'server_id';

# 若不一致，可设置临时ID（重启失效）
set global server_id = 1;

# 查询Master状态，并记录 File 和 Position 的值
show master status;

# 注意：执行完此步骤后退出主数据库，防止再次操作导致 File 和 Position 的值发生变化
```

- 从数据库中设置主数据库

```
# 登录
mysql -uroot -p

# 查询server_id是否可配置文件中一致
show variables like 'server_id';

# 若不一致，可设置临时ID（重启失效）
set global server_id = 2;

# 设置主数据库参数
change master to master_host='192.168.133.129',master_port=3306,master_user='slave',master_password='password',master_log_file='mysql-bin.000002',master_log_pos=156;

# 开始同步
start slave;

# 若出现错误，则停止同步，重置后再次启动
stop slave;
reset slave;
start slave;

# 查询Slave状态
show slave status\G

# 查看是否配置成功
# 查看参数 Slave_IO_Running 和 Slave_SQL_Running 是否都为yes，则证明配置成功。若为no，则需要查看对应的 Last_IO_Error 或 Last_SQL_Error 的异常值。
```

