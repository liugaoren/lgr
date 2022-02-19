### 部署Redis

#### 1.搜索redis镜像

```
docker search redis
```

#### 2.拉取redis镜像

```
docker pull redis:5.0
```

#### 3.创建容器，设置端口映射

```
docker run -id --name=c_redis -p 6379:6379 redis:5.0
```

#### 4.使用外部机器连接redis

```
./redis-cli.exe -h 192.168.149.135 -p 6379
```



### 部署Tomcat

#### 1.搜索tomcat镜像

```
docker search tomcat
```

#### 2.拉取tomcat镜像

```
docker pull tomcat
```

#### 3.创建容器，设置端口映射、目录映射

```
mkdir ~/tomcat
cd ~/tomcat
```

```
docker run -id --name=c_tomcat \
-p 8080:8080 \
-v $PWD:/usr/local/tomcat/webapps \
tomcat 
```

\- 参数说明：

  **-p 8080:8080**:将容器的8080端口映射到主机的8080端口

  **-v $PWD:/usr/local/tomcat/webapps：**将主机中当前目录挂载到容器的webapps



### 部署nginx

#### 1.搜索nginx镜像

```
docker search nginx
```

#### 2.拉取nginx镜像

```
docker pull nginx
```

#### 3.创建容器，设置端口映射、目录映射

在/root目录下创建nginx目录用于存储nginx数据信息

```
mkdir ~/nginx
cd ~/nginx
mkdir conf
cd conf
```

在~/nginx/conf/下创建nginx.conf文件,粘贴下面内容

```
user  nginx;

worker_processes  1;

error_log  /var/log/nginx/error.log warn;

pid        /var/run/nginx.pid;

events {
    worker_connections  1024;
}

http {

    include       /etc/nginx/mime.types;

    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    
    #tcp_nopush     on;
    keepalive_timeout  65;
    
    #gzip  on;
    include /etc/nginx/conf.d/*.conf;
}
```

```
docker run -id --name=c_nginx \
-p 80:80 \
-v $PWD/conf/nginx.conf:/etc/nginx/nginx.conf \
-v $PWD/logs:/var/log/nginx \
-v $PWD/html:/usr/share/nginx/html \
nginx
```

\- 参数说明：

  \- **-p 80:80**：将容器的 80端口映射到宿主机的 80 端口。

  \- **-v $PWD/conf/nginx.conf:/etc/nginx/nginx.conf**：将主机当前目录下的 /conf/nginx.conf 挂载到容器的 :/etc/nginx/nginx.conf。配置目录

  \- **-v $PWD/logs:/var/log/nginx**：将主机当前目录下的 logs 目录挂载到容器的/var/log/nginx。日志目录