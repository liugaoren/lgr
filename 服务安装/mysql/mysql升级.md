### mysql升级

#### 步骤 1：备份数据

在进行任何升级之前，务必备份你的数据和配置文件。

```
mysqldump -u root -p --all-databases > all-databases-backup.sql
cp -r /usr/local/mysql/data /usr/local/mysql/data-backup
cp /usr/local/mysql/my.cnf /usr/local/mysql/my.cnf-backup
```

#### 步骤 2：停止 MySQL 服务

```
sudo systemctl stop mysql
```

#### 步骤 3：解压新版本二进制包

```
tar -xvf mysql-8.0.30-linux-glibc2.12-x86_64.tar.xz
```

步骤 4：移动并替换旧的 MySQL 目录

```
sudo mv /usr/local/mysql /usr/local/mysql-8.0.11
sudo mv mysql-8.0.30-linux-glibc2.12-x86_64 /usr/local/mysql
```

#### 步骤 5：更新权限

```
sh
复制代码
sudo chown -R mysql:mysql /usr/local/mysql
```

#### 步骤 6：升级数据目录

在进行数据目录升级前，确保你使用的是新版本的 `mysql` 二进制文件。

```
sh复制代码cd /usr/local/mysql/bin
sudo ./mysqld --initialize --user=mysql --datadir=/usr/local/mysql/data
sudo ./mysql_upgrade -u root -p
```

#### 步骤 7：启动 MySQL 服务

```
sudo systemctl start mysql
```

#### 步骤 8：验证升级

登录 MySQL 并验证版本号。

```
mysql -u root -p -e "SELECT VERSION();"
```

完成上述步骤后，你的 MySQL 应该已经从 8.0.11 成功升级到 8.0.30。