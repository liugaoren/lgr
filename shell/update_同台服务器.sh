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
APP_DIR="/home/app"
BACKUP_DIR="/home/app/last"
JAR_NAME="${PROJECT_NAME}.jar"

# 确保必要目录存在
mkdir -p "$SOURCE_DIR" "$APP_DIR" "$BACKUP_DIR"

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

# 步骤3: 备份本地Jar包
log "正在备份本地Jar文件..."
if [ -f "$APP_DIR/$JAR_NAME" ]; then
  BACKUP_NAME="${JAR_NAME%.*}_$(date '+%Y%m%d%H%M%S').jar"
  mv "$APP_DIR/$JAR_NAME" "$BACKUP_DIR/$BACKUP_NAME"
  log "已备份当前Jar文件为: $BACKUP_NAME"
else
  log "未发现需要备份的Jar文件，跳过备份步骤。"
fi

# 步骤4: 复制新Jar文件到本地目录
log "正在复制新Jar文件到 $APP_DIR..."
cp "$JAR_PATH" "$APP_DIR/$JAR_NAME"
if [ $? -ne 0 ]; then
  log "Jar文件复制失败！" && exit 1
fi

# 步骤5: 停止旧进程
log "正在尝试停止旧服务..."
if pgrep -f "$JAR_NAME" > /dev/null; then
  pkill -f "$JAR_NAME"
  log "旧服务已停止。"
else
  log "未发现正在运行的旧服务，跳过停止步骤。"
fi

# 步骤6: 启动新Jar包
log "正在启动新服务..."
nohup java -jar "$APP_DIR/$JAR_NAME" > /dev/null 2>&1 &
if [ $? -ne 0 ]; then
  log "启动新服务失败！" && exit 1
fi

log "部署完成，服务已成功启动！"
