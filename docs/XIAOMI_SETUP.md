# 米家设备集成配置指南

本指南详细说明如何在 Home Assistant 中集成小米米家智能设备。

## 前提条件

- Home Assistant 已安装并运行
- 小米账号（已绑定米家设备）
- 米家 app 中的设备在线

## 推荐方案：通过 HACS 安装 Xiaomi Home 集成 ⭐

**为什么推荐这个方案？**
- ✅ 避免官方集成的登录问题
- ✅ 支持更多米家设备和功能
- ✅ 更好的设备兼容性
- ✅ 社区活跃维护

### 第一步：安装 HACS

HACS（Home Assistant Community Store）是社区商店，可以安装各种社区集成。

#### 1.1 在 Docker 容器中安装 HACS

```bash
# 进入 Home Assistant 容器
docker exec -it homeassistant bash

# 下载并安装 HACS
wget -O - https://get.hacs.xyz | bash -

# 退出容器
exit
```

#### 1.2 重启 Home Assistant

```bash
docker-compose restart homeassistant
```

等待 30-60 秒让容器完全启动。

#### 1.3 在 Home Assistant 中配置 HACS

1. 访问 `http://localhost:8123`
2. 进入 **设置** > **设备与服务**
3. 你会看到 **HACS** 出现在集成列表中
4. 点击 **HACS**，按照向导完成配置：
   - 同意条款
   - 使用 GitHub 账号授权（需要 GitHub 账号）
   - 完成配置

⚠️ **如果跳转 URL 包含 `homeassistant.local`**，手动改为 `localhost`

### 第二步：通过 HACS 安装 Xiaomi Home 集成

#### 2.1 打开 HACS

1. 在 Home Assistant 左侧菜单找到 **HACS**
2. 点击进入 HACS 界面

#### 2.2 搜索并安装 Xiaomi Home

1. 点击右下角 **+ 浏览并下载存储库**
2. 在搜索框输入：**Xiaomi Home**
3. 选择 **Xiaomi Home** 集成（作者：XiaoMi）
4. 点击 **下载**
5. 选择最新版本
6. 点击 **下载**

#### 2.3 重启 Home Assistant

```bash
docker-compose restart homeassistant
```

### 第三步：配置 Xiaomi Home 集成

#### 3.1 添加集成

1. 访问 `http://localhost:8123`
2. 进入 **设置** > **设备与服务**
3. 点击右下角 **+ 添加集成**
4. 搜索 **Xiaomi Home**
5. 点击选择

⚠️ **重要**：如果跳转的 URL 包含 `homeassistant.local`，手动改为 `localhost`

#### 3.2 选择登录方式

Xiaomi Home 集成提供两种登录方式：

**方式 A：账号密码登录（简单）**
- 输入小米账号（手机号或邮箱）
- 输入密码
- 选择服务器区域（中国大陆选 **中国**）

**方式 B：扫码登录（推荐，避免登录问题）** ⭐
- 选择"扫码登录"
- 使用米家 app 扫描二维码
- 在手机上确认授权
- 无需输入密码，避免服务器区域选择错误

#### 3.3 等待设备发现

- 系统会自动发现你的米家设备
- 可能需要 1-3 分钟
- 发现后会显示设备列表

#### 3.4 选择设备

- 勾选要添加的设备
- 点击 **提交**
- 设备将被添加到 Home Assistant

---

## 备选方案：使用官方 Xiaomi Miio 集成

如果你不想安装 HACS，也可以使用 Home Assistant 官方内置的 **Xiaomi Miio** 集成。

**优点**：
- ✅ 无需安装，开箱即用
- ✅ 官方维护

**缺点**：
- ❌ 可能遇到登录问题（服务器区域选择）
- ❌ 支持的设备较少

### 配置步骤

1. 进入 **设置** > **设备与服务**
2. 点击 **+ 添加集成**
3. 搜索 **Xiaomi Miio**
4. 输入账号密码
5. **关键**：中国大陆用户必须选择 **cn** 服务器

如果遇到登录问题，建议使用上面推荐的 HACS + Xiaomi Home 方案。

### 4. 选择设备

- 勾选要添加的设备
- 点击 **提交**

设备将被添加到 Home Assistant。

## 支持的设备类型

### 灯具
- 智能灯泡（Yeelight、米家等）
- 智能灯带
- 吸顶灯
- 台灯

### 开关与插座
- 智能插座
- 墙壁开关
- 无线开关

### 传感器
- 温湿度传感器
- 门窗传感器
- 人体传感器
- 光照传感器
- 烟雾传感器
- 水浸传感器

### 气候设备
- 空调
- 空调伴侣
- 电暖器
- 加湿器
- 除湿器

### 清洁设备
- 扫地机器人
- 扫拖一体机

### 其他设备
- 空气净化器
- 风扇
- 摄像头
- 智能门锁
- 窗帘电机

## 高级配置

### 使用 secrets.yaml 存储凭证

编辑 `~/.homeassistant/secrets.yaml`：

```yaml
xiaomi_username: your_email@example.com
xiaomi_password: your_password
```

### 本地控制（需要 Token）

某些设备支持本地控制，需要获取设备 Token：

1. 使用米家 app 的开发者模式
2. 或使用第三方工具获取

配置示例：

```yaml
xiaomi_miot:
  - host: 192.168.1.100
    token: your_device_token
```

### 自定义设备属性

在集成选项中可以自定义：
- 设备名称
- 更新频率
- 启用/禁用特定功能

## 登录问题排查（重要）

如果遇到"无法登录 Xiaomi Home，请检查凭据"错误，请按以下步骤排查：

### 问题 1：服务器区域选择错误 ⭐ 最常见

**症状**：提示"无法登录"或"凭据错误"

**原因**：中国大陆注册的小米账号必须使用 `cn` 服务器

**解决方案**：
1. 删除失败的集成配置
2. 重新添加集成
3. **确保选择 `cn` 或 `中国` 服务器**
4. 重新输入账号密码

**服务器区域对照表**：
| 账号注册地 | 服务器选择 |
|----------|----------|
| 中国大陆 | cn |
| 欧洲 | de |
| 美国 | us |
| 俄罗斯 | ru |
| 台湾 | tw |
| 新加坡 | sg |
| 印度 | in 或 i2 |

参考：https://www.openhab.org/addons/bindings/miio/#country-servers

### 问题 2：使用了第三方登录账号

**症状**：输入微信/QQ 绑定的手机号无法登录

**原因**：集成不支持第三方登录方式

**解决方案**：
1. 打开米家 app
2. 进入"我的" > "设置" > "账号与安全"
3. 如果没有设置密码，点击"密码"设置一个
4. 使用手机号/邮箱 + 密码登录 Home Assistant

### 问题 3：需要验证码

**症状**：提示需要验证或安全验证

**解决方案**：
1. 打开米家 app
2. 退出登录
3. 重新登录，完成所有验证（短信验证码、滑块验证等）
4. 登录成功后，返回 Home Assistant 重试

### 问题 4：账号被临时锁定

**症状**：多次尝试后仍然失败

**原因**：频繁失败尝试导致账号被临时锁定

**解决方案**：
1. 等待 15-30 分钟
2. 在米家 app 中成功登录一次
3. 然后在 Home Assistant 中重试

### 问题 5：网络连接问题

**症状**：长时间无响应或超时

**检查方法**：
```bash
# 检查容器网络
docker exec homeassistant ping -c 3 account.xiaomi.com

# 检查 DNS 解析
docker exec homeassistant nslookup account.xiaomi.com
```

**解决方案**：
1. 检查 Docker 网络配置
2. 确认容器可以访问外网
3. 检查防火墙设置
4. 尝试重启 Docker Desktop

### 问题 6：URL 重定向错误

**症状**：点击添加集成后跳转到 `homeassistant.local` 无法访问

**原因**：macOS Docker 环境下 mDNS 域名解析限制

**解决方案**：
1. 手动修改浏览器地址栏
2. 将 `homeassistant.local` 替换为 `localhost`
3. 按回车重新加载页面

## 常见问题

### Q: 登录失败？

**最可能的原因**：服务器区域选择错误

**快速解决**：
1. 中国大陆用户：选择 **cn** 服务器
2. 使用小米账号（手机号/邮箱）+ 密码，不要用第三方登录
3. 先在米家 app 中完成验证

### Q: 设备无法发现？

**解决方案：**
1. 确认设备在米家 app 中在线
2. 等待几分钟后刷新
3. 重新加载集成：
   - 配置 > 设备与服务
   - 找到 Xiaomi Miot Auto
   - 点击 **重新加载**

### Q: 设备控制失败？

**解决方案：**
1. 检查设备在米家 app 中是否可控制
2. 检查网络连接
3. 查看 Home Assistant 日志：
   ```bash
   tail -f ~/.homeassistant/home-assistant.log | grep xiaomi
   ```

### Q: 设备状态不更新？

**解决方案：**
1. 调整更新频率（在集成选项中）
2. 检查小米云端服务状态
3. 考虑使用本地控制（需要 Token）

### Q: 某些功能不可用？

**解决方案：**
1. 确认设备型号支持该功能
2. 更新 Xiaomi Miot Auto 到最新版本
3. 在集成选项中启用高级功能

## 设备示例

### 智能灯泡

```yaml
# 自动化示例：日落时开灯
automation:
  - alias: "日落开灯"
    trigger:
      platform: sun
      event: sunset
    action:
      service: light.turn_on
      target:
        entity_id: light.yeelight_living_room
      data:
        brightness: 200
        color_temp: 370
```

### 扫地机器人

```yaml
# 脚本示例：清扫客厅
script:
  clean_living_room:
    alias: "清扫客厅"
    sequence:
      - service: vacuum.send_command
        target:
          entity_id: vacuum.xiaomi_vacuum
        data:
          command: app_segment_clean
          params: [18]  # 房间 ID
```

### 空气净化器

```yaml
# 自动化示例：PM2.5 过高时开启
automation:
  - alias: "空气质量差时开启净化器"
    trigger:
      platform: numeric_state
      entity_id: sensor.air_quality_pm25
      above: 75
    action:
      service: fan.turn_on
      target:
        entity_id: fan.xiaomi_air_purifier
```

## 性能优化

### 减少云端请求

1. 使用本地控制（需要 Token）
2. 增加更新间隔
3. 禁用不需要的设备

### 批量操作

使用场景或脚本批量控制设备：

```yaml
scene:
  - name: 离家模式
    entities:
      light.all_lights: off
      climate.all_ac: off
      switch.all_switches: off
```

## 调试

启用米家集成调试日志：

```yaml
logger:
  default: info
  logs:
    homeassistant.components.xiaomi_miio: debug
    homeassistant.components.xiaomi_miot: debug
    custom_components.xiaomi_miot_raw: debug
```

查看日志：

```bash
tail -f ~/.homeassistant/home-assistant.log | grep -i xiaomi
```

## 与 HomeKit 集成

米家设备可以通过 Home Assistant 桥接到 HomeKit：

1. 在 Home Assistant 中添加米家设备
2. 配置 HomeKit 集成包含这些设备
3. 在 iPhone 家庭 app 中即可控制

示例配置：

```yaml
homekit:
  filter:
    include_entities:
      - light.yeelight_living_room
      - switch.xiaomi_plug
      - climate.xiaomi_ac
```

## 安全建议

1. **使用强密码**：确保小米账号使用强密码
2. **定期更新**：保持集成组件更新
3. **网络隔离**：考虑将智能设备放在独立网络

## 参考资源

- [Xiaomi Miot Auto GitHub](https://github.com/al-one/hass-xiaomi-miot)
- [Home Assistant 小米集成文档](https://www.home-assistant.io/integrations/xiaomi_miio/)
- [米家开发者平台](https://iot.mi.com/)

## 获取设备 Token

### 方法 1：使用 Android 米家 app

1. 启用开发者模式（连续点击版本号 5 次）
2. 在设备列表中查看 Token

### 方法 2：使用第三方工具

```bash
# 安装 miio 工具
npm install -g miio

# 发现设备
miio discover

# 获取 Token
miio --discover
```

### 方法 3：从 iOS 备份提取

使用 iCloud 备份提取工具获取米家 app 数据。

## 常用设备 ID

在自动化中使用房间 ID：

```python
# 获取房间列表
service: xiaomi_miot.get_room_mapping
```

结果会显示在 Home Assistant 日志中。
