# mDNS 和 Xiaomi 登录问题快速修复指南

## 问题 1：无法访问 homeassistant.local

### 症状
- 浏览器显示"无法访问此网站"
- 错误：找不到 homeassistant.local 的服务器 IP 地址

### 快速解决（1 分钟）

**直接使用 localhost 访问：**
```
http://localhost:8123
```

### 永久解决（5 分钟）

1. 编辑配置文件：
```bash
nano config/configuration.yaml
```

2. 在文件开头添加：
```yaml
homeassistant:
  external_url: "http://localhost:8123"
  internal_url: "http://localhost:8123"

http:
  server_host: 0.0.0.0
  cors_allowed_origins:
    - http://localhost:8123
    - http://127.0.0.1:8123
```

3. 保存并重启：
```bash
docker-compose restart homeassistant
```

4. 等待 30 秒后访问：
```
http://localhost:8123
```

---

## 问题 2：Xiaomi 集成登录失败

### 症状
```
无法登录 Xiaomi Home，请检查凭据
```

### 推荐解决方案：使用 HACS + Xiaomi Home 集成 ⭐

**为什么推荐？**
- ✅ 支持扫码登录，避免服务器区域选择问题
- ✅ 更好的设备兼容性
- ✅ 避免官方集成的各种登录问题

**快速安装（5 分钟）**：

```bash
# 1. 安装 HACS
docker exec -it homeassistant bash
wget -O - https://get.hacs.xyz | bash -
exit

# 2. 重启
docker-compose restart homeassistant

# 3. 配置 HACS（需要 GitHub 账号）
# 访问 http://localhost:8123
# 进入"设置" > "设备与服务" > 配置 HACS

# 4. 在 HACS 中搜索并安装 "Xiaomi Home"

# 5. 重启后添加 Xiaomi Home 集成，选择扫码登录
```

详细步骤：查看 [HACS 安装指南](HACS_INSTALLATION.md)

---

### 备选方案：使用官方 Xiaomi Miio 集成

如果不想安装 HACS，可以尝试以下方法：

#### 快速检查清单

#### ✅ 第 1 步：确认服务器区域

**中国大陆用户必须选择 `cn` 服务器！**

| 你的账号注册地 | 选择服务器 |
|--------------|----------|
| 中国大陆 | cn |
| 欧洲 | de |
| 美国 | us |
| 其他 | 查看文档 |

#### ✅ 第 2 步：确认账号类型

- ✅ 使用：小米账号（手机号或邮箱）+ 密码
- ❌ 不要用：微信/QQ 登录

如果没有密码：
1. 打开米家 app
2. 进入"我的" > "设置" > "账号与安全"
3. 设置密码

#### ✅ 第 3 步：完成验证

1. 打开米家 app
2. 退出登录
3. 重新登录，完成所有验证
4. 然后在 Home Assistant 中重试

#### ✅ 第 4 步：修复 URL 重定向

如果跳转到 `homeassistant.local`：
1. 复制地址栏的 URL
2. 将 `homeassistant.local` 改为 `localhost`
3. 按回车

例如：
```
原始：http://homeassistant.local:8123/_my_redirect/config_flow_start?domain=xiaomi_miio
修改：http://localhost:8123/_my_redirect/config_flow_start?domain=xiaomi_miio
```

### 运行诊断脚本

```bash
./scripts/check-xiaomi-connection.sh
```

这个脚本会自动检查：
- 容器状态
- 网络连接
- 小米服务器可达性
- DNS 解析
- 配置文件
- 错误日志

---

## 问题 3：集成配置页面无法打开

### 症状
点击"添加集成"后页面无法加载

### 解决方案

**方法 1：手动修改 URL**
1. 查看地址栏
2. 如果包含 `homeassistant.local`，改为 `localhost`
3. 刷新页面

**方法 2：配置内部 URL**
1. 编辑 `config/configuration.yaml`
2. 添加：
```yaml
homeassistant:
  internal_url: "http://localhost:8123"
```
3. 重启容器：
```bash
docker-compose restart homeassistant
```

---

## 常见错误代码

### 错误 1：服务器区域错误
```
Error: Invalid credentials
```
**解决**：中国用户选择 `cn` 服务器

### 错误 2：需要验证
```
Error: Verification required
```
**解决**：在米家 app 中完成验证

### 错误 3：账号锁定
```
Error: Account locked
```
**解决**：等待 15-30 分钟，在米家 app 中登录一次

### 错误 4：网络超时
```
Error: Connection timeout
```
**解决**：检查 Docker 网络，运行诊断脚本

---

## 一键修复命令

### 修复 mDNS 问题
```bash
# 1. 备份配置
cp config/configuration.yaml config/configuration.yaml.backup

# 2. 添加 URL 配置（如果还没有）
cat >> config/configuration.yaml << 'EOF'

homeassistant:
  external_url: "http://localhost:8123"
  internal_url: "http://localhost:8123"

http:
  server_host: 0.0.0.0
  cors_allowed_origins:
    - http://localhost:8123
    - http://127.0.0.1:8123
EOF

# 3. 重启容器
docker-compose restart homeassistant

# 4. 等待启动
sleep 30

# 5. 测试访问
curl -I http://localhost:8123
```

### 检查 Xiaomi 连接
```bash
# 运行诊断
./scripts/check-xiaomi-connection.sh

# 查看 Xiaomi 日志
docker-compose logs homeassistant | grep -i xiaomi | tail -20

# 测试小米服务器连接
docker exec homeassistant ping -c 3 account.xiaomi.com
```

---

## 获取帮助

如果以上方法都无法解决问题：

1. **查看详细文档**：
   - `docs/XIAOMI_SETUP.md` - Xiaomi 集成详细配置
   - `docs/TROUBLESHOOTING.md` - 完整故障排除指南

2. **查看日志**：
```bash
# 查看所有日志
docker-compose logs -f homeassistant

# 只看 Xiaomi 相关
docker-compose logs homeassistant | grep -i xiaomi

# 只看错误
docker-compose logs homeassistant | grep -i error
```

3. **检查配置**：
```bash
# 验证配置文件
docker exec homeassistant python3 -m homeassistant --script check_config --config /config
```

4. **社区支持**：
   - Home Assistant 中文论坛：https://bbs.hassbian.com/
   - 官方社区：https://community.home-assistant.io/

---

## 预防措施

### 避免 mDNS 问题
- ✅ 始终使用 `localhost:8123` 访问
- ✅ 在配置文件中设置 `internal_url`
- ✅ 书签保存 `http://localhost:8123`

### 避免 Xiaomi 登录问题
- ✅ 记住你的服务器区域（中国用户用 cn）
- ✅ 使用小米账号 + 密码，不用第三方登录
- ✅ 定期在米家 app 中登录保持账号活跃
- ✅ 不要频繁重试避免账号锁定

---

**最后更新**：2025-12-02
