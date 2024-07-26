### mysql数据恢复

#### 1.查看最新的biglog日志

```
show master status
或
show binary logs;
```

### 2.大致确定数据在哪个日志中，导出txt文件便于查询

```
mysqlbinlog -vv binlog.000011 > binlog.txt
```

#### 3.使用命令导出sql（注意服务器时间和mysql时间要一致）

```
mysqlbinlog --start-datetime="2024-07-26 09:32:28" --stop-datetime="2024-07-26 10:32:39" /usr/local/mysql/data/binlog.000011 -r  ~/test2.sql
```

#### 4.数据恢复

```
mysql -p123456 < test2.sql 
```

