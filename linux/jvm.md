#### 1.top

![top](images/image.png)

#### 2.top -Hp 14105

![image1](images/image1.png)

#### 3.执行 printf '%x' 15379 获取 16 进制的线程 id，用于dump信息查询，结果为 3c13。

#### 4.jstack 14105 |grep -A 20 3c13

