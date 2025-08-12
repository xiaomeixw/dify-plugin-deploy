# Dify Plugin Deploy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

[English](./README_EN.md) | 中文

一个用于 Dify Plugin Daemon 的 Docker 镜像构建、打包和部署工具集。

## 📋 项目简介

本项目提供了一套完整的脚本工具，用于：
- 🔨 构建 Dify Plugin Daemon 的 Docker 镜像
- 🚀 快速部署和启动 Plugin Daemon 服务
- ⚙️ 灵活的配置管理和环境变量支持
- 🔧 支持多架构（AMD64/ARM64）构建

## 🚀 快速开始

### 前提条件

- Docker 已安装并运行
- Bash 环境（Linux/macOS）
- 确保有足够的磁盘空间用于构建镜像

### 1. 构建 Docker 镜像

使用 `build-local-docker.sh` 脚本构建本地 Docker 镜像：

```bash
chmod +x build-local-docker.sh
./build-local-docker.sh
```

脚本会自动：
- 📖 读取版本信息
- 🏗️ 检测系统架构（ARM64/AMD64）
- 🔨 构建相应的 Docker 镜像
- 📤 可选择上传到 Harbor 仓库

### 2. 启动 Plugin Daemon

使用 `start-plugin-daemon.sh` 脚本启动服务：

```bash
chmod +x start-plugin-daemon.sh
./start-plugin-daemon.sh
```

## 📁 脚本详解

### build-local-docker.sh

**功能**：构建 Dify Plugin Daemon 的本地 Docker 镜像

**主要特性**：
- ✅ 自动检测系统架构
- ✅ 从 version 文件读取版本信息
- ✅ 支持交互式确认
- ✅ 可选的 Harbor 镜像推送
- ✅ 跨平台兼容（macOS/Linux）

**使用示例**：
```bash
# 基本使用
./build-local-docker.sh

# 构建完成后，镜像名称格式为：
# your-harbor-registry.com/library/dify-plugin-daemon:{版本}-{架构}-local
```

**脚本工作流程**：
1. 检测脚本目录和项目根目录
2. 读取 `version` 文件中的版本信息
3. 检测当前系统架构
4. 生成 Docker 镜像标签
5. 执行 Docker 构建命令
6. 可选择推送到 Harbor 仓库

### start-plugin-daemon.sh

**功能**：启动 Plugin Daemon 容器，包含完整的环境配置

**主要特性**：
- 🔧 丰富的环境变量配置
- 🔒 端口冲突检测
- 📊 数据持久化支持
- 🔄 容器自动重启
- 📋 详细的启动日志

## ⚙️ 配置选项

> **⚠️ 重要提示**：在生产环境中使用前，请务必修改以下默认配置：
> - 替换 `your-harbor-registry.com` 为你的实际镜像仓库地址
> - 修改 `your-db-password` 和 `your-redis-password` 为强密码
> - 更新所有默认的认证信息和密钥

### 环境变量配置

| 变量名 | 默认值 | 描述 |
|--------|--------|------|
| `DATA_DIR` | `$HOME/plugin_daemon_data` | 数据存储目录 |
| `DOCKER_IMAGE` | `your-harbor-registry.com/library/dify-plugin-daemon:0.1.3-v8-amd-local` | Docker 镜像名称 |
| `EXPOSE_PLUGIN_DAEMON_PORT` | `5002` | 主服务端口 |
| `EXPOSE_PLUGIN_DEBUGGING_PORT` | `5003` | 调试端口 |
| `DB_HOST` | `localhost` | 数据库主机 |
| `DB_PORT` | `5432` | 数据库端口 |
| `DB_USER` | `postgres` | 数据库用户名 |
| `DB_PASSWORD` | `your-db-password` | 数据库密码 |
| `DB_PLUGIN_DATABASE` | `dify_plugin` | 插件数据库名 |
| `REDIS_HOST` | `127.0.0.1` | Redis 主机 |
| `REDIS_PORT` | `6379` | Redis 端口 |
| `REDIS_PASSWORD` | `your-redis-password` | Redis 密码 |
| `PIP_MIRROR_URL` | `https://mirrors.aliyun.com/pypi/simple` | Python 包镜像源 |

### 使用自定义配置

```bash
# 使用自定义数据目录和端口
export DATA_DIR="/custom/data/path"
export EXPOSE_PLUGIN_DAEMON_PORT=8002
export EXPOSE_PLUGIN_DEBUGGING_PORT=8003
./start-plugin-daemon.sh
```

## 🔧 高级用法

### 自定义数据库连接

```bash
export DB_HOST="your-db-host"
export DB_PORT=5432
export DB_USER="your-username"
export DB_PASSWORD="your-password"
export DB_PLUGIN_DATABASE="your-database"
./start-plugin-daemon.sh
```

### 使用外部 Redis

```bash
export REDIS_HOST="your-redis-host"
export REDIS_PORT=6379
export REDIS_PASSWORD="your-redis-password"
./start-plugin-daemon.sh
```

### 启用镜像拉取和日志显示

```bash
export PULL_IMAGE=true
export SHOW_LOGS=true
./start-plugin-daemon.sh
```

## 📊 容器管理

启动后，你可以使用以下命令管理容器：

```bash
# 查看容器状态
docker ps | grep plugin_daemon

# 查看实时日志
docker logs -f plugin_daemon

# 停止服务
docker stop plugin_daemon

# 重启服务
docker start plugin_daemon

# 删除容器
docker rm -f plugin_daemon

# 进入容器
docker exec -it plugin_daemon /bin/bash
```

## 🔍 故障排除

### 常见问题

1. **端口被占用**
   ```bash
   # 检查端口占用
   netstat -tuln | grep :5002
   # 或使用 ss 命令
   ss -tuln | grep :5002
   ```

2. **Docker 镜像拉取失败**
   ```bash
   # 手动拉取镜像
   docker pull your-harbor-registry.com/library/dify-plugin-daemon:0.1.3-v8-amd-local
   ```

3. **数据库连接失败**
   - 检查数据库服务是否运行
   - 验证连接参数是否正确
   - 确认防火墙设置

4. **容器启动失败**
   ```bash
   # 查看详细错误信息
   docker logs plugin_daemon
   ```

### 日志分析

```bash
# 查看最近100行日志
docker logs --tail 100 plugin_daemon

# 实时查看日志
docker logs -f plugin_daemon

# 查看特定时间的日志
docker logs --since="2024-01-01T00:00:00" plugin_daemon
```

## 🤝 贡献指南

欢迎提交 Issue 和 Pull Request！

1. Fork 本项目
2. 创建你的特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交你的修改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启一个 Pull Request

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情。

## 🔗 相关链接

- [Dify 官方网站](https://dify.ai/)
- [Docker 官方文档](https://docs.docker.com/)
- [Bash 脚本指南](https://www.gnu.org/software/bash/manual/)

## ❓ 支持

如果你遇到任何问题，请：
1. 查看本 README 的故障排除部分
2. 搜索现有的 Issues
3. 创建新的 Issue 并提供详细信息

---

⭐ 如果这个项目对你有帮助，请给它一个 Star！
