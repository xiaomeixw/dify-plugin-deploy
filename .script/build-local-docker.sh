#!/bin/bash

# =============================================================================
# Dify Plugin Daemon Docker Image Build Script
# =============================================================================
# 
# Description: Build local Docker images for Dify Plugin Daemon
# Author: Dify Plugin Deploy Team
# Version: 1.0
# 
# Features:
# - Auto-detect system architecture (ARM64/AMD64)
# - Read version from version file
# - Interactive build confirmation
# - Optional Harbor registry push
# - Cross-platform compatibility (macOS/Linux)
# 
# Usage:
#   ./build-local-docker.sh
# 
# =============================================================================

# Exit immediately if a command exits with a non-zero status
# 如果命令以非零状态退出，立即退出脚本
set -e

# Function to get script directory (compatible with macOS and Linux)
# 获取脚本所在目录（兼容MacOS和Linux）
get_script_path() {
    local source="${BASH_SOURCE[0]}"
    # Handle symbolic links
    # 处理符号链接
    while [ -h "$source" ]; do
        local dir="$(cd -P "$(dirname "$source")" && pwd)"
        source="$(readlink "$source")"
        [[ $source != /* ]] && source="$dir/$source"
    done
    echo "$(cd -P "$(dirname "$source")" && pwd)"
}

# Get script directory
# 获取脚本目录
SCRIPT_DIR=$(get_script_path)

# Project root directory (one level up from script directory)
# 项目根目录（脚本目录的上一级）
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# =============================================================================
# Version and Architecture Detection
# 版本和架构检测
# =============================================================================

# Read version information from version file (using absolute path to root dir)
# 从版本文件读取版本信息（使用根目录的绝对路径）
OFFICIAL_VERSION=$(grep -o '"official_version": "[^"]*' "${ROOT_DIR}/version" | cut -d '"' -f 4)
LOCAL_VERSION=$(grep -o '"local_version": "[^"]*' "${ROOT_DIR}/version" | cut -d '"' -f 4)
VERSION="${OFFICIAL_VERSION}-${LOCAL_VERSION}"

# Detect system architecture and set appropriate suffix
# 检测系统架构并设置相应的后缀
ARCH=$(uname -m)
if [ "$ARCH" = "arm64" ] || [ "$ARCH" = "aarch64" ]; then
    ARCH_SUFFIX="-arm"
else
    ARCH_SUFFIX="-amd"
fi

# Generate image tag and full image name
# 生成镜像标签和完整镜像名称
IMAGE_TAG="${VERSION}${ARCH_SUFFIX}-local"
FULL_IMAGE_NAME="your-harbor-registry.com/library/dify-plugin-daemon:$IMAGE_TAG"

# =============================================================================
# Build Information Display
# 构建信息显示
# =============================================================================

echo "Building docker image with:"
echo "  Version: $VERSION"
echo "  Architecture: $ARCH_SUFFIX"
echo "  Image tag: $IMAGE_TAG"

# =============================================================================
# Docker Build Command Preparation
# Docker构建命令准备
# =============================================================================

# Build complete Docker command
# Switch to project root directory to execute Docker command
# 构建完整的 Docker 命令
# 切换到项目根目录执行Docker命令
DOCKER_CMD="cd \"${ROOT_DIR}\" && docker build --build-arg PLATFORM=local --build-arg VERSION=$VERSION$ARCH_SUFFIX -t $FULL_IMAGE_NAME -f ./docker/local.dockerfile ."

# Display the command that will be executed
# 打印将要执行的命令
echo -e "\n即将执行的命令:"
echo "$DOCKER_CMD"
echo -e "\n确认执行? (y/n)"
read -r confirm

# =============================================================================
# Build Execution and Harbor Upload
# 构建执行和Harbor上传
# =============================================================================

if [[ "$confirm" =~ ^[Yy]$ ]]; then
    # Execute Docker build command
    # 执行 Docker 构建命令
    eval "$DOCKER_CMD"
    echo "Docker image built successfully: $FULL_IMAGE_NAME"
    
    # Ask whether to upload to Harbor
    # 询问是否上传到Harbor
    echo -e "\n是否需要上传镜像到本地Harbor? (y/n)"
    read -r upload_confirm
    
    if [[ "$upload_confirm" =~ ^[Yy]$ ]]; then
        echo "正在登录Harbor..."
        
        # Login to Harbor registry
        # 登录Harbor
        echo "执行: docker login your-harbor-registry.com -u admin -p your-password"
        docker login your-harbor-registry.com -u admin -p your-password
        
        # Check login result
        # 检查登录结果
        if [ $? -eq 0 ]; then
            echo "登录成功，正在上传镜像..."
            
            # Push image to Harbor
            # 上传镜像
            echo "执行: docker push $FULL_IMAGE_NAME"
            docker push $FULL_IMAGE_NAME
            
            # Check push result
            # 检查推送结果
            if [ $? -eq 0 ]; then
                echo "镜像上传成功: $FULL_IMAGE_NAME"
            else
                echo "镜像上传失败"
                exit 1
            fi
        else
            echo "Harbor登录失败"
            exit 1
        fi
    else
        echo "已取消上传镜像"
    fi
else
    echo "构建已取消"
    exit 0
fi