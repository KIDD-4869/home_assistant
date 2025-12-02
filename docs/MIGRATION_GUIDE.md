# Home Assistant 安装类型迁移指南

## ⚠️ 重要通知

Home Assistant Core 安装类型（Python 虚拟环境）将在 **2025.12** 版本后不再受官方支持。

虽然你可以继续使用当前设置，但强烈建议迁移到官方支持的安装方法。

## 当前状态

- **安装类型**: Core（Python venv）
- **支持状态**: 将在 2025.12 后弃用
- **当前版本**: 2025.11.3
- **剩余时间**: 约 1 个月

## macOS 推荐的安装方法

### 方案对比

| 方案 | 优点 | 缺点 | 推荐度 |
|------|------|------|--------|
| **Home Assistant Container** | 简单、隔离、官方支持 | 需要 Docker | ⭐⭐⭐⭐⭐ |
| **Home Assistant OS (虚拟机)** | 完整功能、自动更新 | 资源占用高 | ⭐⭐⭐⭐ |
| **继续使用 Core** | 无需迁移 | 不再受官方支持 | ⭐⭐ |

## 推荐方案：迁移到 Docker Container

### 为什么选择 Docker？

1. ✅ **官方支持**: 长期维护
2. ✅ **简单管理**: 一键启动/停止
3. ✅ **环境隔离**: 不影响系统
4. ✅ **易于备份**: 容器化部署
5. ✅ **自动更新**: 简化升级流程

### 注意事项

⚠️ **重要**: Docker 的 `network_mode: host` 在 macOS 上不完全支持，这会影响：
- HomeKit 集成（mDNS 功能）
- 某些网络发现功能

**解决方案**:
1. 使用端口映射代替 host 网络
2. 对于 HomeKit，考虑使用 Home Assistant OS 虚拟机
3. 或继续使用 Core 安装（社区支持）

## 迁移步骤

### 准备工作

1. **备份当前配置**
   ```bash
   ./scripts/backup-homeassistant.sh
   ```

2. **记录当前设置**
   - 已安装的集成
   - 自动化规则
   - 设备配置
   - 自定义组件

3. **安装 Docker Desktop**
   ```bash
   brew install --cask docker
   ```
   
   启动 Docker Desktop 应用

### 方案 1: Docker Container（推荐用于非 HomeKit 用户）

#### 1. 创建 Docker Compose 配置

创建 `docker-compose-ha.yaml`:

```yaml
version: '3'
services:
  homeassistant:
    container_name: homeassistant
    image: ghcr.io/home-assistant/home-assistant:stable
    volumes:
      - ./ha-config:/config
      - /etc/localtime:/etc/localtime:ro
    restart: unless-stopped
    privileged: true
    ports:
      - "8123:8123"
    environment:
      - TZ=Asia/Shanghai
```

#### 2. 迁移配置

```bash
# 创建配置目录
mkdir -p ha-config

# 复制配置文件
cp ~/.homeassistant/*.yaml ha-config/
cp -r ~/.homeassistant/.storage ha-config/
cp -r ~/.homeassistant/custom_components ha-config/ 2>/dev/null || true
```

#### 3. 启动容器

```bash
docker-compose -f docker-compose-ha.yaml up -d
```

#### 4. 验证

访问 http://localhost:8123

#### 5. 停止旧服务

```bash
launchctl stop com.homeassistant.server
launchctl unload ~/Library/LaunchAgents/com.homeassistant.server.plist
```

### 方案 2: Home Assistant OS（推荐用于 HomeKit 用户）

#### 1. 安装虚拟化软件

```bash
# 选项 1: UTM (推荐，原生 Apple Silicon)
brew install --cask utm

# 选项 2: VirtualBox
brew install --cask virtualbox
```

#### 2. 下载 Home Assistant OS

访问: https://www.home-assistant.io/installation/macos

下载适合你 Mac 的镜像：
- Apple Silicon (M1/M2/M3): `haos_ova-*.qcow2`
- Intel: `haos_ova-*.vmdk`

#### 3. 创建虚拟机

**UTM 配置**:
- 内存: 4GB
- CPU: 2 核心
- 磁盘: 32GB
- 网络: 桥接模式

**VirtualBox 配置**:
- 内存: 4GB
- CPU: 2 核心
- 磁盘: 32GB
- 网络: 桥接适配器

#### 4. 启动并配置

1. 启动虚拟机
2. 等待 Home Assistant OS 初始化（约 5-10 分钟）
3. 访问 http://homeassistant.local:8123
4. 完成初始设置

#### 5. 恢复配置

通过 Web 界面上传备份文件，或手动复制配置。

### 方案 3: 继续使用 Core（不推荐）

如果你决定继续使用 Core 安装：

**优点**:
- 无需迁移
- 熟悉的环境
- 完全控制

**缺点**:
- 不再有官方支持
- 可能遇到兼容性问题
- 需要自行解决问题

**注意事项**:
- 定期备份配置
- 关注社区支持
- 准备好未来可能需要迁移

## 迁移后验证清单

- [ ] Home Assistant 正常启动
- [ ] 所有集成正常工作
- [ ] 设备可以控制
- [ ] 自动化规则正常执行
- [ ] HomeKit 连接正常（如使用）
- [ ] 米家设备正常（如使用）
- [ ] 备份功能正常

## Docker 管理命令

```bash
# 启动
docker-compose -f docker-compose-ha.yaml up -d

# 停止
docker-compose -f docker-compose-ha.yaml down

# 重启
docker-compose -f docker-compose-ha.yaml restart

# 查看日志
docker-compose -f docker-compose-ha.yaml logs -f

# 更新
docker-compose -f docker-compose-ha.yaml pull
docker-compose -f docker-compose-ha.yaml up -d

# 进入容器
docker exec -it homeassistant bash
```

## 性能对比

| 指标 | Core | Docker | Home Assistant OS |
|------|------|--------|-------------------|
| 启动时间 | 快 | 中等 | 慢 |
| 内存占用 | 低 | 中等 | 高 |
| 管理复杂度 | 高 | 低 | 最低 |
| 功能完整性 | 高 | 高 | 最高 |
| HomeKit 支持 | 完整 | 受限 | 完整 |

## 常见问题

### Q: 必须迁移吗？

A: 不是强制的，但强烈建议。2025.12 后 Core 安装将不再有官方支持。

### Q: 迁移会丢失数据吗？

A: 不会。通过备份和恢复，所有配置和数据都可以保留。

### Q: Docker 方案支持 HomeKit 吗？

A: 在 macOS 上支持有限。如果 HomeKit 是必需的，建议使用 Home Assistant OS 虚拟机。

### Q: 可以同时运行两个实例吗？

A: 可以，但需要使用不同的端口和配置目录。这对测试迁移很有用。

### Q: 迁移需要多长时间？

A: 
- Docker: 30-60 分钟
- Home Assistant OS: 1-2 小时
- 包括测试和验证

### Q: 如果迁移失败怎么办？

A: 你的原始配置仍然保留，可以随时回滚到 Core 安装。

## 推荐时间表

1. **现在 - 2025.11**: 
   - 了解迁移选项
   - 测试 Docker 或虚拟机方案
   - 创建完整备份

2. **2025.12 发布前**:
   - 完成迁移
   - 验证所有功能
   - 删除旧的 Core 安装

3. **2025.12 发布后**:
   - 享受官方支持的安装方式
   - 定期更新

## 获取帮助

- [Home Assistant 安装文档](https://www.home-assistant.io/installation/)
- [Docker 安装指南](https://www.home-assistant.io/installation/macos#install-home-assistant-container)
- [社区论坛](https://community.home-assistant.io/)
- [Discord 频道](https://discord.gg/home-assistant)

## 总结

虽然 Core 安装类型被弃用，但这是 Home Assistant 向更标准化、更易维护方向发展的一部分。

**我们的建议**:
- 如果不使用 HomeKit: 迁移到 **Docker Container**
- 如果使用 HomeKit: 迁移到 **Home Assistant OS (虚拟机)**
- 如果想继续 Core: 了解风险并做好准备

无论选择哪种方案，记得先备份配置！

---

**文档更新**: 2025-12-02  
**适用版本**: Home Assistant 2025.11+  
**迁移截止**: 2025.12 发布前
