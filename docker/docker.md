## docker容器安装

### centos命令：

#### 1.安装需要的软件包， yum-util 提供yum-config-manager功能，另外两个是devicemapper驱动依赖的 

```
yum install -y yum-utils device-mapper-persistent-data lvm2
```

#### 2.设置yum源

```
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```

#### 3. 安装docker，出现输入的界面都按 y 

```
yum install -y docker-ce
```

### 4.查看docker版本，验证是否验证成功

```
docker -v
```