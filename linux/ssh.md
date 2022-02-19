#### **远程连接：**

```
ssh root@101.35.245.41 -p 22
```

然后输入密码：123456

#### **远程传输文件：**

```
scp 数据源 root@101.35.245.41:/usr/local/
```

#### **免密登录：**

1.创建.ssh文件

```
ssh-keygen -t rsa -b 4096
```

2.将公钥复制到linux

```
ssh-copy-id root@101.35.245.41
```

#### **ssh取别名：**

使用cd ~/.ssh/ 进入ssh目录，会看到有config、known_hosts两个文件，一般的没有设置的话，只会有known_hosts，可以使用touch config命令创建config文件。

```
Host jhd
HostName 1xx.1xx.1xx.67
User root
IdentitiesOnly yes
```

多个用换行分割