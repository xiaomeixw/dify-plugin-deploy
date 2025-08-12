# Dify Plugin Deploy

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Shell](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)

English | [中文](./README.md)

A comprehensive toolkit for building, packaging, and deploying Dify Plugin Daemon Docker images.

## 📋 Project Overview

This project provides a complete set of script tools for:
- 🔨 Building Dify Plugin Daemon Docker images
- 🚀 Quick deployment and startup of Plugin Daemon services
- ⚙️ Flexible configuration management and environment variable support
- 🔧 Multi-architecture (AMD64/ARM64) build support

## 🚀 Quick Start

### Prerequisites

- Docker installed and running
- Bash environment (Linux/macOS)
- Sufficient disk space for image building

### 1. Build Docker Image

Use the `build-local-docker.sh` script to build local Docker images:

```bash
chmod +x build-local-docker.sh
./build-local-docker.sh
```

The script will automatically:
- 📖 Read version information
- 🏗️ Detect system architecture (ARM64/AMD64)
- 🔨 Build corresponding Docker images
- 📤 Optionally upload to Harbor registry

### 2. Start Plugin Daemon

Use the `start-plugin-daemon.sh` script to start the service:

```bash
chmod +x start-plugin-daemon.sh
./start-plugin-daemon.sh
```

## 📁 Script Details

### build-local-docker.sh

**Function**: Build local Docker images for Dify Plugin Daemon

**Key Features**:
- ✅ Automatic system architecture detection
- ✅ Read version information from version file
- ✅ Interactive confirmation support
- ✅ Optional Harbor image push
- ✅ Cross-platform compatibility (macOS/Linux)

**Usage Example**:
```bash
# Basic usage
./build-local-docker.sh

# After building, image name format:
# your-harbor-registry.com/library/dify-plugin-daemon:{version}-{arch}-local
```

**Script Workflow**:
1. Detect script directory and project root
2. Read version information from `version` file
3. Detect current system architecture
4. Generate Docker image tags
5. Execute Docker build command
6. Optional push to Harbor registry

### start-plugin-daemon.sh

**Function**: Start Plugin Daemon container with complete environment configuration

**Key Features**:
- 🔧 Rich environment variable configuration
- 🔒 Port conflict detection
- 📊 Data persistence support
- 🔄 Container auto-restart
- 📋 Detailed startup logs

## ⚙️ Configuration Options

> **⚠️ Important Notice**: Before using in production, please make sure to modify the following default configurations:
> - Replace `your-harbor-registry.com` with your actual image registry address
> - Change `your-db-password` and `your-redis-password` to strong passwords
> - Update all default authentication information and keys

### Environment Variables

| Variable | Default Value | Description |
|----------|---------------|-------------|
| `DATA_DIR` | `$HOME/plugin_daemon_data` | Data storage directory |
| `DOCKER_IMAGE` | `your-harbor-registry.com/library/dify-plugin-daemon:0.1.3-v8-amd-local` | Docker image name |
| `EXPOSE_PLUGIN_DAEMON_PORT` | `5002` | Main service port |
| `EXPOSE_PLUGIN_DEBUGGING_PORT` | `5003` | Debug port |
| `DB_HOST` | `localhost` | Database host |
| `DB_PORT` | `5432` | Database port |
| `DB_USER` | `postgres` | Database username |
| `DB_PASSWORD` | `your-db-password` | Database password |
| `DB_PLUGIN_DATABASE` | `dify_plugin` | Plugin database name |
| `REDIS_HOST` | `127.0.0.1` | Redis host |
| `REDIS_PORT` | `6379` | Redis port |
| `REDIS_PASSWORD` | `your-redis-password` | Redis password |
| `PIP_MIRROR_URL` | `https://mirrors.aliyun.com/pypi/simple` | Python package mirror |

### Using Custom Configuration

```bash
# Use custom data directory and ports
export DATA_DIR="/custom/data/path"
export EXPOSE_PLUGIN_DAEMON_PORT=8002
export EXPOSE_PLUGIN_DEBUGGING_PORT=8003
./start-plugin-daemon.sh
```

## 🔧 Advanced Usage

### Custom Database Connection

```bash
export DB_HOST="your-db-host"
export DB_PORT=5432
export DB_USER="your-username"
export DB_PASSWORD="your-password"
export DB_PLUGIN_DATABASE="your-database"
./start-plugin-daemon.sh
```

### Using External Redis

```bash
export REDIS_HOST="your-redis-host"
export REDIS_PORT=6379
export REDIS_PASSWORD="your-redis-password"
./start-plugin-daemon.sh
```

### Enable Image Pull and Log Display

```bash
export PULL_IMAGE=true
export SHOW_LOGS=true
./start-plugin-daemon.sh
```

## 📊 Container Management

After startup, you can manage the container with these commands:

```bash
# Check container status
docker ps | grep plugin_daemon

# View real-time logs
docker logs -f plugin_daemon

# Stop service
docker stop plugin_daemon

# Restart service
docker start plugin_daemon

# Remove container
docker rm -f plugin_daemon

# Enter container
docker exec -it plugin_daemon /bin/bash
```

## 🔍 Troubleshooting

### Common Issues

1. **Port Already in Use**
   ```bash
   # Check port usage
   netstat -tuln | grep :5002
   # Or use ss command
   ss -tuln | grep :5002
   ```

2. **Docker Image Pull Failed**
   ```bash
   # Manually pull image
   docker pull your-harbor-registry.com/library/dify-plugin-daemon:0.1.3-v8-amd-local
   ```

3. **Database Connection Failed**
   - Check if database service is running
   - Verify connection parameters are correct
   - Confirm firewall settings

4. **Container Startup Failed**
   ```bash
   # View detailed error information
   docker logs plugin_daemon
   ```

### Log Analysis

```bash
# View last 100 lines of logs
docker logs --tail 100 plugin_daemon

# View real-time logs
docker logs -f plugin_daemon

# View logs from specific time
docker logs --since="2024-01-01T00:00:00" plugin_daemon
```

## 🤝 Contributing

Issues and Pull Requests are welcome!

1. Fork this project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Related Links

- [Dify Official Website](https://dify.ai/)
- [Docker Official Documentation](https://docs.docker.com/)
- [Bash Scripting Guide](https://www.gnu.org/software/bash/manual/)

## ❓ Support

If you encounter any issues, please:
1. Check the troubleshooting section in this README
2. Search existing Issues
3. Create a new Issue with detailed information

---

⭐ If this project helps you, please give it a Star! 