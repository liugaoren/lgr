# 🐳 Kafka 安全认证 + ACL 权限配置笔记

## 1️⃣ 开启 SASL SCRAM 认证

### 修改 Broker 配置 `server.properties`

```properties
# 开启 SASL_PLAINTEXT 监听
listeners=SASL_PLAINTEXT://0.0.0.0:9092
advertised.listeners=SASL_PLAINTEXT://192.168.253.133:9092

# Broker 间通信也使用 SASL
security.inter.broker.protocol=SASL_PLAINTEXT
sasl.mechanism.inter.broker.protocol=SCRAM-SHA-256
sasl.enabled.mechanisms=SCRAM-SHA-256

# 开启 ACL 权限控制
authorizer.class.name=kafka.security.authorizer.AclAuthorizer
super.users=User:admin
```

* * *

## 2️⃣ 创建 JAAS 文件

创建 `/opt/kafka/config/kafka_server_jaas.conf`：

```conf
KafkaServer {
    org.apache.kafka.common.security.scram.ScramLoginModule required
    username="admin"
    password="admin-secret";
};
```

注意：启动前要先用kafka-configs.sh创建这个用户

### 持久化 JVM 参数

在`kafka-server-start.sh`上加入， 或修改全局环境变量：

```bash
export KAFKA_OPTS="-Djava.security.auth.login.config=/opt/kafka/config/kafka_server_jaas.conf"
```

* * *

## 3️⃣ 创建用户

### 创建 Broker 间通信用户（admin:admin-secret）

```bash
kafka-configs.sh \
  --zookeeper localhost:2181 \
  --alter \
  --add-config 'SCRAM-SHA-256=[password=admin-secret]' \
  --entity-type users \
  --entity-name admin
```

### 创建普通客户端用户（root）

```bash
kafka-configs.sh \
  --zookeeper localhost:2181 \
  --alter \
  --add-config 'SCRAM-SHA-256=[password=123456]' \
  --entity-type users \
  --entity-name root
```

* * *

## 4️⃣ 设置 ACL 权限

### 允许 `root` 读取 `test` 主题

```bash
kafka-acls.sh \
  --authorizer-properties zookeeper.connect=localhost:2181 \
  --add --allow-principal User:root \
  --operation Read \
  --topic test
```

### 禁止 `root` 写入 `test` 主题

```bash
kafka-acls.sh \
  --authorizer-properties zookeeper.connect=localhost:2181 \
  --add --deny-principal User:root \
  --operation Write \
  --topic test
```

### 允许 `root` 读取所有 Consumer Group

```bash
kafka-acls.sh \
  --authorizer-properties zookeeper.connect=localhost:2181 \
  --add --allow-principal User:root \
  --operation Read \
  --group '*'
```

### 查看用户权限

```bash
kafka-acls.sh \
  --authorizer-properties zookeeper.connect=localhost:2181 \
  --list --principal User:root
```

* * *

## 5️⃣ 客户端（Spring Boot / Kafka Tools）连接配置

### Spring Boot `application.yml`

```yaml
spring:
  kafka:
    bootstrap-servers: 192.168.253.133:9092
    properties:
      security.protocol: SASL_PLAINTEXT
      sasl.mechanism: SCRAM-SHA-256
      sasl.jaas.config: org.apache.kafka.common.security.scram.ScramLoginModule required username="root" password="123456";
    consumer:
      group-id: kafka-demo-group
      auto-offset-reset: earliest
      key-deserializer: org.apache.kafka.common.serialization.StringDeserializer
      value-deserializer: org.apache.kafka.common.serialization.StringDeserializer
    producer:
      key-serializer: org.apache.kafka.common.serialization.StringSerializer
      value-serializer: org.apache.kafka.common.serialization.StringSerializer
```

### Kafka Tools 配置

* `Security Protocol` → `SASL_PLAINTEXT`
  
* `SASL Mechanism` → `SCRAM-SHA-256`
  
* `JAAS Config`：
  

```text
org.apache.kafka.common.security.scram.ScramLoginModule required
    username="root"
    password="123456";
```

* * *

## 6️⃣ 查看用户、密码、权限

### 查看所有用户

```bash
kafka-configs.sh \
  --zookeeper localhost:2181 \
  --entity-type users \
  --describe
```

### 查看特定用户

```bash
kafka-configs.sh \
  --zookeeper localhost:2181 \
  --entity-type users \
  --entity-name root \
  --describe
```

> ⚠️ Kafka 不显示明文密码，只能看到是否配置了 SCRAM。

### 查看用户权限

```bash
kafka-acls.sh \
  --authorizer-properties zookeeper.connect=localhost:2181 \
  --list --principal User:root
```

