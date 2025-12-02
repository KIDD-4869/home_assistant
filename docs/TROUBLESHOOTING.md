# 故障排除指南

本文档提供 Home Assistant 常见问题的解决方案。

## 安装问题

### Python 版本不兼容

**症状：**
```
ERROR: This package requires Python 3.11 or higher
```

**解决方案：**
```bash
# 安装 Python 3.12
brew install python@3.12

# 重新创建虚拟环境
rm -rf ~/homeassistant-venv
/opt/homebrew/bin/python3.12 -m venv ~/homeassistant-venv
source ~/homeassistant-venv/bin/activate
pip install homeassistant
```

### 依赖安装失败

**症状：**
```
ERROR: Could not install packages due to an OSError
```

**解决方案：**
```bash
# 升级 pip
pip install --upgrade pip

# 清理缓存
pip cache purge

# 重新安装
pip install homeassistant
```

## 启动问题

### 端口被占用

**症状：**
```
ERROR: Port 8123 is already in use
```

**解决方案：**
```bash
# 查找占用端口的进程
lsof -i :8123

# 终止进程
kill -9 <PID>

# 或更改端口
# 编辑 configuration.yaml
http:
  server_port: 8124
```

### 配置文件错误

**症状：**
```
ERROR: Invalid config for [homeassistant]
```

**解决方案：**
```bash
# 验证配置
source ~/homeassistant-venv/bin/activate
hass --script check_config -c ~/.homeassistant

# 检查 YAML 语法
# 确保使用空格而非 Tab
# 确保缩进正确
```

### 权限问题

**症状：**
```
PermissionError: [Errno 13] Permission denied
```

**解决方案：**
```bash
# 修复配置目录权限
chmod -R 755 ~/.homeassistant
chown -R $(whoami) ~/.homeassistant
```

## HomeKit 问题

### iPhone 找不到桥接设备

**解决方案：**

1. **检查网络连接**
   ```bash
   # 确认 Mac 和 iPhone 在同一网络
   ifconfig | grep inet
   ```

2. **检查 mDNS 服务**
   ```bash
   # 验证 mDNS 广播
   dns-sd -B _hap._tcp
   ```

3. **检查防火墙**
   - 系统偏好设置 > 安全性与隐私 > 防火墙
   - 确保允许 Home Assistant

4. **重启 Home Assistant**
   ```bash
   launchctl stop com.homeassistant.server
   launchctl start com.homeassistant.server
   ```

### 配对失败

**解决方案：**

1. **重置 HomeKit 配对**
   ```bash
   # 停止服务
   launchctl stop com.homeassistant.server
   
   # 删除 HomeKit 存储
   rm ~/.homeassistant/.storage/homekit.*
   
   # 启动服务
   launchctl start com.homeassistant.server
   ```

2. **检查配对码**
   ```bash
   # 查看日志获取配对码
   tail -f ~/.homeassistant/home-assistant.log | grep -i homekit
   ```

### 设备无响应

**解决方案：**

1. **检查设备状态**
   - 在 Home Assistant 中确认设备在线

2. **重启 HomeKit 桥接**
   ```bash
   # 在 Home Assistant Web 界面
   # 配置 > 集成 > HomeKit > 重新加载
   ```

3. **重新配对**
   - 在家庭 app 中删除配件
   - 重新添加

## 米家集成问题

### 登录失败

**解决方案：**

1. **验证账号密码**
   - 在米家 app 中确认可以登录

2. **选择正确区域**
   - 中国大陆用户：选择"中国"
   - 其他地区：选择对应区域

3. **处理验证码**
   - 在米家 app 中完成验证
   - 等待几分钟后重试

### 设备无法发现

**解决方案：**

1. **确认设备在线**
   - 在米家 app 中检查设备状态

2. **重新加载集成**
   ```bash
   # Web 界面：配置 > 设备与服务
   # 找到 Xiaomi Miot Auto > 重新加载
   ```

3. **检查日志**
   ```bash
   tail -f ~/.homeassistant/home-assistant.log | grep -i xiaomi
   ```

### 控制延迟

**解决方案：**

1. **使用本地控制**
   - 获取设备 Token
   - 配置本地连接

2. **优化网络**
   - 确保网络稳定
   - 减少设备数量

## 服务问题

### 服务无法启动

**症状：**
```bash
launchctl list | grep homeassistant
# 无输出
```

**解决方案：**

1. **检查 plist 文件**
   ```bash
   cat ~/Library/LaunchAgents/com.homeassistant.server.plist
   # 确认路径正确
   ```

2. **手动加载服务**
   ```bash
   launchctl load ~/Library/LaunchAgents/com.homeassistant.server.plist
   launchctl start com.homeassistant.server
   ```

3. **查看错误日志**
   ```bash
   tail -f ~/.homeassistant/homeassistant.err.log
   ```

### 服务频繁重启

**解决方案：**

1. **检查配置错误**
   ```bash
   hass --script check_config -c ~/.homeassistant
   ```

2. **查看崩溃日志**
   ```bash
   tail -100 ~/.homeassistant/home-assistant.log
   ```

3. **临时禁用自动重启**
   - 编辑 plist 文件
   - 将 `KeepAlive` 设为 `false`
   - 手动启动进行调试

## 性能问题

### 启动缓慢

**解决方案：**

1. **减少集成数量**
   - 禁用不需要的集成

2. **优化数据库**
   ```yaml
   recorder:
     purge_keep_days: 7
     exclude:
       domains:
         - automation
         - updater
   ```

3. **使用 SQLite 优化**
   ```bash
   sqlite3 ~/.homeassistant/home-assistant_v2.db "VACUUM;"
   ```

### 内存占用高

**解决方案：**

1. **限制历史记录**
   ```yaml
   recorder:
     purge_keep_days: 3
   ```

2. **禁用不需要的日志**
   ```yaml
   logger:
     default: warning
   ```

3. **重启服务**
   ```bash
   launchctl stop com.homeassistant.server
   launchctl start com.homeassistant.server
   ```

## 网络问题

### 无法访问 Web 界面

**解决方案：**

1. **检查服务状态**
   ```bash
   launchctl list | grep homeassistant
   ```

2. **检查端口**
   ```bash
   lsof -i :8123
   ```

3. **检查防火墙**
   ```bash
   # 系统偏好设置 > 安全性与隐私 > 防火墙
   ```

4. **尝试其他浏览器**
   - 清除浏览器缓存
   - 使用隐私模式

### 外部访问问题

**解决方案：**

1. **配置外部 URL**
   ```yaml
   homeassistant:
     external_url: "https://your-domain.com"
   ```

2. **使用 Nabu Casa**
   - 订阅 Home Assistant Cloud
   - 自动配置远程访问

3. **配置反向代理**
   - 使用 Nginx 或 Caddy
   - 配置 SSL 证书

## 数据库问题

### 数据库损坏

**症状：**
```
ERROR: Database is malformed
```

**解决方案：**

1. **备份数据库**
   ```bash
   cp ~/.homeassistant/home-assistant_v2.db ~/ha_db_backup.db
   ```

2. **尝试修复**
   ```bash
   sqlite3 ~/.homeassistant/home-assistant_v2.db "PRAGMA integrity_check;"
   ```

3. **重建数据库**
   ```bash
   # 停止服务
   launchctl stop com.homeassistant.server
   
   # 删除数据库
   rm ~/.homeassistant/home-assistant_v2.db
   
   # 启动服务（会创建新数据库）
   launchctl start com.homeassistant.server
   ```

## 升级问题

### 升级后无法启动

**解决方案：**

1. **检查兼容性**
   - 查看发布说明
   - 确认配置更改

2. **回滚版本**
   ```bash
   source ~/homeassistant-venv/bin/activate
   pip install homeassistant==2024.12.0  # 指定版本
   ```

3. **从备份恢复**
   ```bash
   ./scripts/restore-homeassistant.sh <backup_file>
   ```

## 日志分析

### 查看实时日志

```bash
# 应用日志
tail -f ~/.homeassistant/home-assistant.log

# 服务输出
tail -f ~/.homeassistant/homeassistant.out.log

# 服务错误
tail -f ~/.homeassistant/homeassistant.err.log
```

### 过滤特定组件

```bash
# HomeKit 日志
tail -f ~/.homeassistant/home-assistant.log | grep -i homekit

# 米家日志
tail -f ~/.homeassistant/home-assistant.log | grep -i xiaomi

# 错误日志
tail -f ~/.homeassistant/home-assistant.log | grep -i error
```

### 启用调试日志

```yaml
logger:
  default: info
  logs:
    homeassistant.components.homekit: debug
    homeassistant.components.xiaomi_miot: debug
```

## 获取帮助

### 社区资源

- [Home Assistant 官方论坛](https://community.home-assistant.io/)
- [Home Assistant 中文论坛](https://bbs.hassbian.com/)
- [GitHub Issues](https://github.com/home-assistant/core/issues)

### 提交问题时包含

1. Home Assistant 版本
2. macOS 版本
3. 相关配置文件
4. 错误日志
5. 重现步骤

### 诊断信息

```bash
# 系统信息
sw_vers

# Home Assistant 版本
source ~/homeassistant-venv/bin/activate
hass --version

# Python 版本
python3 --version

# 配置验证
hass --script check_config -c ~/.homeassistant
```

## 完全重置

如果所有方法都失败，可以完全重置：

```bash
# 1. 备份配置
./scripts/backup-homeassistant.sh

# 2. 停止服务
launchctl stop com.homeassistant.server
launchctl unload ~/Library/LaunchAgents/com.homeassistant.server.plist

# 3. 删除所有文件
rm -rf ~/.homeassistant
rm -rf ~/homeassistant-venv
rm ~/Library/LaunchAgents/com.homeassistant.server.plist

# 4. 重新安装
./scripts/install-homeassistant.sh
./scripts/install-service.sh

# 5. 恢复配置
./scripts/restore-homeassistant.sh <backup_file>
```


## mDNS 域名解析问题

### homeassistant.local 无法访问

**症状：**
- 浏览器显示"无法访问此网站"
- 错误信息：`homeassistant.local` 的服务器 IP 地址找不到

**原因：**
macOS Docker Desktop 对 host 网络模式支持有限，导致 Avahi 容器广播的 mDNS 域名无法被 macOS 正确解析。

**解决方案：**

1. **使用 localhost 访问（推荐）**：
   ```
   http://localhost:8123
   ```
   或
   ```
   http://127.0.0.1:8123
   ```

2. **配置 Home Assistant URL**：
   编辑 `config/configuration.yaml`：
   ```yaml
   homeassistant:
     external_url: "http://localhost:8123"
     internal_url: "http://localhost:8123"
   ```
   然后重启容器：
   ```bash
   docker-compose restart homeassistant
   ```

3. **手动修改 URL**：
   如果某个链接跳转到 `homeassistant.local`，手动将地址栏中的域名改为 `localhost`。

### 集成配置重定向错误

**症状：**
- 点击"添加集成"后跳转到 `http://homeassistant.local:8123/_my_redirect/...`
- 页面无法加载

**解决方案：**

1. **手动修改 URL**：
   - 复制地址栏中的完整 URL
   - 将 `homeassistant.local` 替换为 `localhost`
   - 按回车重新加载

   例如：
   ```
   原始：http://homeassistant.local:8123/_my_redirect/config_flow_start?domain=xiaomi_miio
   修改：http://localhost:8123/_my_redirect/config_flow_start?domain=xiaomi_miio
   ```

2. **配置内部 URL**（永久解决）：
   在 `config/configuration.yaml` 中添加：
   ```yaml
   homeassistant:
     internal_url: "http://localhost:8123"
   ```
   重启后所有内部链接都会使用 localhost。

## Xiaomi 集成问题

### 登录失败：无法登录 Xiaomi Home

**症状：**
```
无法登录 Xiaomi Home，请检查凭据
```

**最常见原因：服务器区域选择错误**

**解决方案：**

1. **检查服务器区域**：
   - 中国大陆注册的账号必须选择 **cn** 服务器
   - 其他地区根据注册地选择对应服务器
   - 参考：https://www.openhab.org/addons/bindings/miio/#country-servers

2. **使用正确的账号类型**：
   - 使用小米账号（手机号或邮箱）
   - 不要使用微信/QQ 等第三方登录
   - 如果没有密码，在米家 app 中设置一个

3. **完成验证**：
   - 打开米家 app
   - 退出并重新登录
   - 完成所有验证（短信验证码、滑块等）
   - 然后在 Home Assistant 中重试

4. **等待账号解锁**：
   - 如果多次失败，账号可能被临时锁定
   - 等待 15-30 分钟
   - 在米家 app 中成功登录一次
   - 然后重试

5. **检查网络连接**：
   ```bash
   # 测试容器网络
   docker exec homeassistant ping -c 3 account.xiaomi.com
   
   # 检查 DNS
   docker exec homeassistant nslookup account.xiaomi.com
   ```

**详细排查步骤**：查看 `docs/XIAOMI_SETUP.md` 中的"登录问题排查"章节。

### 设备无法发现

**症状：**
- 登录成功但没有发现设备
- 设备列表为空

**解决方案：**

1. **确认设备在线**：
   - 打开米家 app
   - 确认设备显示在线
   - 尝试在 app 中控制设备

2. **等待更长时间**：
   - 设备发现可能需要 2-5 分钟
   - 刷新页面重试

3. **重新加载集成**：
   - 进入"设置" > "设备与服务"
   - 找到 Xiaomi 集成
   - 点击"重新加载"

4. **检查日志**：
   ```bash
   docker-compose logs homeassistant | grep -i xiaomi
   ```

### 设备控制失败

**症状：**
- 设备显示但无法控制
- 控制命令无响应

**解决方案：**

1. **检查设备状态**：
   - 确认设备在米家 app 中可控制
   - 检查设备是否离线

2. **查看错误日志**：
   ```bash
   docker-compose logs -f homeassistant | grep -i xiaomi
   ```

3. **重启集成**：
   - 进入"设置" > "设备与服务"
   - 找到 Xiaomi 集成
   - 点击"重新加载"

4. **考虑本地控制**：
   - 某些设备可能需要本地控制 token
   - 参考 `docs/XIAOMI_SETUP.md` 获取 token 方法
