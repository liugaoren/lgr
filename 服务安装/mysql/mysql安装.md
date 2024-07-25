### mysql内网安装

#### 1.下载二进制包，解压

```
cd /usr/local

tar -xvf mysql-8.0.11-linux-glibc2.12-x86_64.tar.xz

sudo mv mysql-8.0.11-linux-glibc2.12-x86_64/* /usr/local/mysql/
```

#### 2.创建 MySQL 用户和组

```
sudo groupadd mysql
sudo useradd -r -g mysql mysql
#更改 MySQL 目录的所有者
sudo chown -R mysql:mysql /usr/local/mysql

#创建数据目录并设置权限
sudo mkdir /usr/local/mysql/data
sudo chown mysql:mysql /usr/local/mysql/data

```

#### 3.mysql初始化

```
sudo /usr/local/mysql/bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/usr/local/mysql/data

```

此时控制台会显示localhost@root密码

#### 4.编辑MySQL 配置文件 `/etc/my.cnf`

```
[mysqld]
bind-address=0.0.0.0
basedir = /usr/local/mysql
datadir = /usr/local/mysql/data
socket = /tmp/mysql.sock
pid-file = /usr/local/mysql/mysql.pid

[mysqld_safe]
log-error = /var/log/mysqld.log
pid-file = /var/run/mysqld/mysqld.pid
```

测试是否能启动成功

```
/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf --user=mysql
```

#### 5.设置 MySQL 环境变量

```
vim ~/.bashrc
#增加
export PATH=$PATH:/usr/local/mysql/bin
#刷新配置
source ~/.bashrc

```

#### 6.修改root用户访问权限和密码

```
-- 修改 root 用户的访问权限为允许从任意主机访问
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
CREATE USER 'root'@'%' IDENTIFIED BY '123456';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

-- 刷新权限表
FLUSH PRIVILEGES;
```

#### 7.设置mysql系统服务

创建 MySQL 的服务文件 `/etc/systemd/system/mysqld.service`

```
[Unit]
Description=MySQL Server
Documentation=man:mysqld(8)
Documentation=http://dev.mysql.com/doc/refman/en/using-systemd.html
After=network.target

[Install]
WantedBy=multi-user.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --defaults-file=/etc/my.cnf
LimitNOFILE = 5000

```

启动 MySQL 服务命令

```
# 重新加载 systemd 服务配置
sudo systemctl daemon-reload

# 启动 MySQL 服务
sudo systemctl start mysqld

# 设置 MySQL 开机自启动
sudo systemctl enable mysqld

# 重启 MySQL 服务
sudo systemctl restart mysqld

# 关闭 MySQL 服务
sudo systemctl stop mysqld

# 查看 MySQL 服务状态
sudo systemctl status mysqld

```

