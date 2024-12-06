#!/bin/bash

# 打印日志函数
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# 参数解析
BRANCH_NAME="master"  # 默认分支为master
while getopts ":p:b:" opt; do
  case $opt in
    p) PROJECT_NAME="$OPTARG" ;;
    b) BRANCH_NAME="$OPTARG" ;;
    ?) log "无效的选项: -$OPTARG" && exit 1 ;;
  esac
done

if [ -z "$PROJECT_NAME" ]; then
  log "使用方法: $0 -p <项目名称> [-b <分支名称>]"
  exit 1
fi

# 配置变量
SOURCE_DIR="/var/source"
REMOTE_SERVER="192.168.253.128"  # 替换为目标服务器的IP地址
REMOTE_APP_DIR="/home/app"  #jar包部署位置
REMOTE_BACKUP_DIR="/home/app/last"  #旧jar包备份位置
JAR_NAME="${PROJECT_NAME}.jar"

# 确保必要目录存在
mkdir -p "$SOURCE_DIR"

# 步骤1: 从Git拉取代码
log "正在从Git拉取项目 $PROJECT_NAME 的代码（分支: $BRANCH_NAME）..."
cd "$SOURCE_DIR" || exit
if [ ! -d "$PROJECT_NAME" ]; then
  git clone -b "$BRANCH_NAME" "git@gitee.com:liugaoren123/$PROJECT_NAME.git"
else
  cd "$PROJECT_NAME" || exit
  git fetch
  git checkout "$BRANCH_NAME"
  git pull origin "$BRANCH_NAME"
fi

if [ $? -ne 0 ]; then
  log "Git拉取代码失败！" && exit 1
fi

# 步骤2: 使用Maven编译打包
log "正在使用Maven编译项目 $PROJECT_NAME..."
cd "$SOURCE_DIR/$PROJECT_NAME" || exit
mvn clean package -DskipTests
if [ $? -ne 0 ]; then
  log "Maven编译失败！" && exit 1
fi

# 获取打包后的Jar路径
JAR_PATH=$(find target -name "*.jar" | grep -v "original")
if [ -z "$JAR_PATH" ]; then
  log "未找到打包生成的Jar文件！" && exit 1
fi
log "编译完成，Jar文件路径: $JAR_PATH"

# 步骤3: 备份远程服务器的Jar包
log "正在备份远程服务器上的Jar文件..."
ssh "$REMOTE_SERVER" "
  mkdir -p $REMOTE_BACKUP_DIR
  if [ -f $REMOTE_APP_DIR/$JAR_NAME ]; then
    BACKUP_NAME=\"${JAR_NAME%.*}_$(date '+%Y%m%d%H%M%S').jar\"
    mv $REMOTE_APP_DIR/$JAR_NAME $REMOTE_BACKUP_DIR/\$BACKUP_NAME
    echo \"远程Jar文件已备份为: \$BACKUP_NAME\"
  else
    echo \"未发现需要备份的远程Jar文件，跳过备份步骤。\"
  fi
"

if [ $? -ne 0 ]; then
  log "远程备份失败！" && exit 1
fi

# 步骤4: 发送新Jar包到远程服务器
log "正在将新Jar文件传输到远程服务器..."
scp "$JAR_PATH" "$REMOTE_SERVER:$REMOTE_APP_DIR/$JAR_NAME"
if [ $? -ne 0 ]; then
  log "Jar文件传输失败！" && exit 1
fi

# 步骤5: 停止远程服务器的旧进程
log "正在尝试停止远程服务器上的旧服务..."
ssh "$REMOTE_SERVER" "
  if pgrep -f $JAR_NAME > /dev/null; then
    pkill -f $JAR_NAME
    echo \"旧服务已停止。\"
  else
    echo \"未发现正在运行的旧服务，跳过停止步骤。\"
  fi
"

# 步骤6: 启动新的Jar包
log "正在启动远程服务器上的新服务..."
ssh "$REMOTE_SERVER" "nohup java -jar $REMOTE_APP_DIR/$JAR_NAME > /dev/null 2>&1 &"
if [ $? -ne 0 ]; then
  log "启动新服务失败！" && exit 1
fi

log "部署完成，服务已成功启动！"
