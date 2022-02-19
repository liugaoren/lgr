####  1.在docker中安装FASTDFS

     docker pull delron/fastdfs
#### 2.使用docker镜像构建tracker容器（跟踪服务器，起到调度的作用）

    docker run -dti --network=host --name tracker -v /var/fdfs/tracker:/var/fdfs -v /etc/localtime:/etc/localtime delron/fastdfs tracker

#### 3.使用docker镜像构建storage容器（存储服务器，提供容量和备份服务）：

    docker run -dti  --network=host --name storage -e TRACKER_SERVER=192.168.0.89:22122 -v /var/fdfs/storage:/var/fdfs  -v /etc/localtime:/etc/localtime delron/fastdfs storage
TRACKER_SERVER的ip是服务器的公网ip

#### 4.进入storage容器，到storage的配置文件中配置http访问的端口，配置文件在/etc/fdfs目录下的storage.conf

    默认端口是8888，也可以不进行更改（http端口，ngnix和storage.conf都要改）
如果重启后无法启动的会，可能是报下面错误了，手动创建 vi /var/fdfs/logs/storaged.log 文件即可 

    tail: cannot open '/var/fdfs/logs/storaged.log' for reading: No such file or directory
#### 5.配置nginx

    进入storage,配置nginx，在/usr/local/nginx目录下，修改nginx.conf文件,默认配置不修改也可以

#### 6.进去storage,测试上传文件

    docker exec -it 2072d970d437 /bin/bash
使用web模块进行文件的上传，将文件上传至FastDFS文件系统

    wget https://upload-images.jianshu.io/upload_images/11693390-a26b21909429f7d2.png
将该图片通过命令上传到分布式系统中

    /usr/bin/fdfs_upload_file /etc/fdfs/client.conf 11693390-a26b21909429f7d2.png
会返回一个路径

    group1/M00/00/00/wKhYW2Dge9iAKqIkAC-ojGdpZlE656.png

使用浏览器进行访问

    http://192.168.0.89:8888/group1/M00/00/00/wKhYW2Dge9iAKqIkAC-ojGdpZlE656.png

#### 7.开启启动容器

    docker update --restart=always tracker
    
    docker update --restart=always storage



_注意：上传失败无法访问时检查防火墙是否关闭，或者是否开放22122和23000端口_
