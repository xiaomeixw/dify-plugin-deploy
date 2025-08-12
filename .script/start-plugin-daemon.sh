#!/bin/bash

# =============================================================================
# Dify Plugin Daemon Container Startup Script
# =============================================================================
# 
# Description: Standalone script to start plugin_daemon container
# Author: Dify Plugin Deploy Team
# Version: 1.0
# 
# Features:
# - Rich environment variable configuration
# - Port conflict detection
# - Data persistence support
# - Container auto-restart
# - Detailed startup logs
# - Interactive confirmation and logging
# 
# Usage:
#   ./start-plugin-daemon.sh
# 
# Environment Variables:
#   All configuration can be overridden via environment variables
#   See the configuration section below for details
# 
# =============================================================================

# =============================================================================
# Configuration Variables (can be overridden by environment variables)
# 配置变量，允许通过环境变量覆盖
# =============================================================================
# Basic runtime configuration
# 基础运行时配置
DATA_DIR=${DATA_DIR:-"$HOME/plugin_daemon_data"}          # Data storage directory / 数据存储目录
PULL_IMAGE=${PULL_IMAGE:-false}                           # Whether to pull latest image / 是否拉取最新镜像
SHOW_LOGS=${SHOW_LOGS:-true}                             # Whether to show logs after startup / 启动后是否显示日志

# Port configuration
# 端口配置
EXPOSE_PLUGIN_DAEMON_PORT=${EXPOSE_PLUGIN_DAEMON_PORT:-5002}      # Host port for main service / 主服务的主机端口
PLUGIN_DAEMON_PORT=${PLUGIN_DAEMON_PORT:-5002}                    # Container port for main service / 主服务的容器端口
EXPOSE_PLUGIN_DEBUGGING_PORT=${EXPOSE_PLUGIN_DEBUGGING_PORT:-5003} # Host port for debugging / 调试的主机端口
PLUGIN_DEBUGGING_PORT=${PLUGIN_DEBUGGING_PORT:-5003}              # Container port for debugging / 调试的容器端口

# Database and Redis configuration (can be overridden)
# 数据库和Redis配置 - 允许覆盖
DB_HOST=${DB_HOST:-localhost}                                      # Database host / 数据库主机
REDIS_HOST=${REDIS_HOST:-127.0.0.1}                              # Redis host / Redis主机
PLUGIN_DIFY_INNER_API_URL=${PLUGIN_DIFY_INNER_API_URL:-http://localhost:5001}  # Dify inner API URL / Dify内部API地址
DIFY_PLUGIN_SERVERLESS_CONNECTOR_URL=${DIFY_PLUGIN_SERVERLESS_CONNECTOR_URL:-http://127.0.0.1:5004}  # Serverless connector URL / 无服务器连接器地址

# Database detailed configuration
# 数据库详细配置
DB_PORT=${DB_PORT:-5432}                                   # Database port / 数据库端口
DB_USER=${DB_USER:-"postgres"}                             # Database username / 数据库用户名
DB_PASSWORD=${DB_PASSWORD:-"your-db-password"}             # Database password / 数据库密码
DB_PLUGIN_DATABASE=${DB_PLUGIN_DATABASE:-"dify_plugin"}    # Plugin database name / 插件数据库名

# Redis detailed configuration
# Redis详细配置
REDIS_PORT=${REDIS_PORT:-6379}                            # Redis port / Redis端口
REDIS_PASSWORD=${REDIS_PASSWORD:-"your-redis-password"}   # Redis password / Redis密码

# Python package management configuration
# Python包管理配置
PIP_MIRROR_URL=${PIP_MIRROR_URL:-"https://mirrors.aliyun.com/pypi/simple"}  # Python package mirror / Python包镜像源
UV_HTTP_TIMEOUT=${UV_HTTP_TIMEOUT:-120}                   # UV HTTP timeout in seconds / UV HTTP超时时间（秒）

# Container image configuration
# 容器镜像配置
DOCKER_IMAGE=${DOCKER_IMAGE:-"your-harbor-registry.com/library/dify-plugin-daemon:0.1.3-v8-amd-local"}  # Docker image name / Docker镜像名称

# Network configuration
# 网络配置
DIFY_NODE_IP=${DIFY_NODE_IP:-127.0.0.1}                   # Dify node IP address / Dify节点IP地址

# =============================================================================
# Directory Setup and Configuration Display
# 目录设置和配置显示
# =============================================================================

# Create data directory if it doesn't exist
# 创建数据目录（如果不存在）
mkdir -p $DATA_DIR

# Display startup configuration
# 显示启动配置
echo "===== Plugin Daemon 启动配置 ====="
echo "数据目录: $DATA_DIR"
echo "数据库连接: $DB_HOST:$DB_PORT"
echo "Redis连接: $REDIS_HOST:$REDIS_PORT"
echo "API地址: $PLUGIN_DIFY_INNER_API_URL"
echo "端口映射: $EXPOSE_PLUGIN_DAEMON_PORT:$PLUGIN_DAEMON_PORT, $EXPOSE_PLUGIN_DEBUGGING_PORT:$PLUGIN_DEBUGGING_PORT"
echo "=================================="

# =============================================================================
# Prerequisites Check
# 前置条件检查
# =============================================================================

# Check if Docker is installed
# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未安装Docker"
    exit 1
fi

# =============================================================================
# Port Conflict Detection
# 端口冲突检测
# =============================================================================

# Function to check if a port is already in use
# 检查端口是否被占用的函数
check_port() {
    # Try netstat first, then ss as fallback
    # 先尝试netstat，如果不可用则使用ss作为备选
    if command -v netstat &> /dev/null; then
        if netstat -tuln | grep -q ":$1 "; then
            return 1  # Port is in use / 端口被占用
        fi
    elif command -v ss &> /dev/null; then
        if ss -tuln | grep -q ":$1 "; then
            return 1  # Port is in use / 端口被占用
        fi
    fi
    return 0  # Port is available / 端口可用
}

# Check main service port
# 检查主服务端口
if ! check_port $EXPOSE_PLUGIN_DAEMON_PORT; then
    echo "警告: 端口 $EXPOSE_PLUGIN_DAEMON_PORT 已被占用，请确保不会导致冲突"
fi

# Check debugging port
# 检查调试端口
if ! check_port $EXPOSE_PLUGIN_DEBUGGING_PORT; then
    echo "警告: 端口 $EXPOSE_PLUGIN_DEBUGGING_PORT 已被占用，请确保不会导致冲突"
fi

# =============================================================================
# Container Management
# 容器管理
# =============================================================================

# Stop and remove existing container (if exists)
# 停止并删除已有容器(如果存在)
if docker ps -a | grep -q "plugin_daemon"; then
    echo "停止并删除已有的plugin_daemon容器..."
    docker rm -f plugin_daemon 2>/dev/null
fi

# Pull latest image (if needed)
# 拉取镜像(如果需要)
if [ "$PULL_IMAGE" = "true" ]; then
    echo "拉取最新的Docker镜像..."
    docker pull $DOCKER_IMAGE
fi

# =============================================================================
# Container Startup
# 容器启动
# =============================================================================

# Start the plugin_daemon container with comprehensive configuration
# 启动plugin_daemon容器，包含完整配置
echo "启动plugin_daemon容器..."
docker run -d --restart always --name plugin_daemon \
  -p $EXPOSE_PLUGIN_DAEMON_PORT:$PLUGIN_DAEMON_PORT \
  -p $EXPOSE_PLUGIN_DEBUGGING_PORT:$PLUGIN_DEBUGGING_PORT \
  -v $DATA_DIR:/app/storage \
  -e DB_HOST=$DB_HOST \
  -e DIFY_NODE_IP=$DIFY_NODE_IP \
  -e DB_PORT=$DB_PORT \
  -e DB_USERNAME=$DB_USER \
  -e DB_PASSWORD=$DB_PASSWORD \
  -e DB_DATABASE=$DB_PLUGIN_DATABASE \
  -e REDIS_HOST=$REDIS_HOST \
  -e REDIS_PORT=$REDIS_PORT \
  -e REDIS_PASSWORD=$REDIS_PASSWORD \
  -e SERVER_PORT=$PLUGIN_DAEMON_PORT \
  -e SERVER_KEY=${PLUGIN_DAEMON_KEY:-lYkiYYT6owG+71oLerGzA7GXCgOT++6ovaezWAjpCjf+Sjc3ZtU+qUEi} \
  -e MAX_PLUGIN_PACKAGE_SIZE=${PLUGIN_MAX_PACKAGE_SIZE:-524288000} \
  -e PPROF_ENABLED=${PLUGIN_PPROF_ENABLED:-false} \
  -e DIFY_INNER_API_URL=$PLUGIN_DIFY_INNER_API_URL \
  -e DIFY_INNER_API_KEY=${PLUGIN_DIFY_INNER_API_KEY:-QaHbTe77CtuXmsfyhR7+vRjI/+XbV1AaFy691iy+kGDv2Jvy0/eAh8Y1} \
  -e PLUGIN_REMOTE_INSTALLING_HOST=${PLUGIN_DEBUGGING_HOST:-0.0.0.0} \
  -e PLUGIN_REMOTE_INSTALLING_PORT=$PLUGIN_DEBUGGING_PORT \
  -e PLUGIN_WORKING_PATH=${PLUGIN_WORKING_PATH:-/app/storage/cwd} \
  -e FORCE_VERIFYING_SIGNATURE=${FORCE_VERIFYING_SIGNATURE:-false} \
  -e PYTHON_ENV_INIT_TIMEOUT=${PLUGIN_PYTHON_ENV_INIT_TIMEOUT:-120} \
  -e UV_HTTP_TIMEOUT=$UV_HTTP_TIMEOUT \
  -e PLUGIN_MAX_EXECUTION_TIMEOUT=${PLUGIN_MAX_EXECUTION_TIMEOUT:-600} \
  -e PIP_MIRROR_URL=$PIP_MIRROR_URL \
  -e PLUGIN_STORAGE_TYPE=${PLUGIN_STORAGE_TYPE:-local} \
  -e PLUGIN_STORAGE_LOCAL_ROOT=${PLUGIN_STORAGE_LOCAL_ROOT:-/app/storage} \
  -e PLUGIN_INSTALLED_PATH=${PLUGIN_INSTALLED_PATH:-plugin} \
  -e PLUGIN_PACKAGE_CACHE_PATH=${PLUGIN_PACKAGE_CACHE_PATH:-plugin_packages} \
  -e PLUGIN_MEDIA_CACHE_PATH=${PLUGIN_MEDIA_CACHE_PATH:-assets} \
  -e PLUGIN_STORAGE_OSS_BUCKET=${PLUGIN_STORAGE_OSS_BUCKET:-} \
  -e S3_USE_AWS_MANAGED_IAM=${PLUGIN_S3_USE_AWS_MANAGED_IAM:-false} \
  -e S3_ENDPOINT=${PLUGIN_S3_ENDPOINT:-} \
  -e S3_USE_PATH_STYLE=${PLUGIN_S3_USE_PATH_STYLE:-false} \
  -e AWS_ACCESS_KEY=${PLUGIN_AWS_ACCESS_KEY:-} \
  -e AWS_SECRET_KEY=${PLUGIN_AWS_SECRET_KEY:-} \
  -e AWS_REGION=${PLUGIN_AWS_REGION:-} \
  -e AZURE_BLOB_STORAGE_CONNECTION_STRING=${PLUGIN_AZURE_BLOB_STORAGE_CONNECTION_STRING:-} \
  -e AZURE_BLOB_STORAGE_CONTAINER_NAME=${PLUGIN_AZURE_BLOB_STORAGE_CONTAINER_NAME:-} \
  -e TENCENT_COS_SECRET_KEY=${PLUGIN_TENCENT_COS_SECRET_KEY:-} \
  -e TENCENT_COS_SECRET_ID=${PLUGIN_TENCENT_COS_SECRET_ID:-} \
  -e TENCENT_COS_REGION=${PLUGIN_TENCENT_COS_REGION:-} \
  -e OBSERVE_ENDPOINT=${PLUGIN_OBSERVE_ENDPOINT:-127.0.0.1:5081} \
  -e OBSERVE_HTTP_ENDPOINT=${PLUGIN_OBSERVE_HTTP_ENDPOINT:-http://127.0.0.1:5080} \
  -e AUTHORIZATION=${PLUGIN_AUTHORIZATION:-"Basic ZnV5dW5mYW5AZGlmeS5jb206YlViSEl4QUIzTWRLdHFTeA=="} \
  -e ORGAN=${PLUGIN_ORGAN:-local} \
  -e STREAM=${PLUGIN_STREAM:-default} \
  -e DIFY_PLUGIN_SERVERLESS_CONNECTOR_URL=$DIFY_PLUGIN_SERVERLESS_CONNECTOR_URL\
  -e SERVICE_NAME=${PLUGIN_SERVICE_NAME:-dify-plugin-mingyue} \
  -e SERVICE_VERSION=${PLUGIN_SERVICE_VERSION:-v0.0.1} \
  --add-host=host.docker.internal:host-gateway \
  $DOCKER_IMAGE

# =============================================================================
# Startup Verification and Management Commands
# 启动验证和管理命令
# =============================================================================

# Check if container started successfully
# 检查容器是否成功启动
if [ $? -eq 0 ]; then
  # Get container ID for reference
  # 获取容器ID作为参考
  CONTAINER_ID=$(docker ps -q -f name=plugin_daemon)
  
  echo "✅ plugin_daemon 容器已成功启动"
  echo "容器ID: $CONTAINER_ID"
  echo "访问地址: http://$(hostname -I 2>/dev/null | awk '{print $1}'):$EXPOSE_PLUGIN_DAEMON_PORT"
  echo "调试端口: $EXPOSE_PLUGIN_DEBUGGING_PORT"
  echo
  echo "管理命令:"
  echo "查看日志: docker logs -f plugin_daemon"
  echo "停止服务: docker stop plugin_daemon"
  echo "启动服务: docker start plugin_daemon"
  echo "删除容器: docker rm -f plugin_daemon"

  # Show logs if requested
  # 显示日志(如果需要)
  if [ "$SHOW_LOGS" = "true" ]; then
    echo
    echo "容器日志输出:"
    docker logs -f plugin_daemon
  fi
else
  # Handle startup failure
  # 处理启动失败
  echo "❌ 启动失败，请检查配置和错误信息"
  docker logs plugin_daemon
fi