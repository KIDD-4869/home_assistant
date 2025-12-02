# HACS 安装指南（Docker 版本）

HACS（Home Assistant Community Store）是 Home Assistant 的社区商店，可以安装各种社区开发的集成和主题。

## 为什么需要 HACS？

- ✅ 安装 Xiaomi Home 集成（避免官方集成的登录问题）
- ✅ 访问数千个社区集成和主题
- ✅ 自动更新管理
- ✅ 简单的图形界面

## 安装步骤

### 第一步：在容器中安装 HACS

```bash
# 进入 Home Assistant 容器
docker exec -it homeassistant bash

# 下载并安装 HACS
wget -O - https://get.hacs.xyz | bash -

# 退出容器
exit
```

**预期输出**：
```
INFO: Downloading HACS
INFO: Installing HACS
INFO: HACS installation complete!
```

### 第二步：重启 Home Assistant

```bash
docker-compose restart homeassistant
```

等待 30-60 秒让容器完全启动。

### 第三步：在 Home Assistant 中配置 HACS

1. 访问 `http://localhost:8123`

2. 进入 **设置** > **设备与服务**

3. 你会看到 **HACS** 出现在"发现的集成"中

4. 点击 **HACS**，开始配置向导

5. **阅读并同意条款**：
   - 勾选所有复选框
   - 点击 **提交**

6. **GitHub 授权**：
   - 点击链接跳转到 GitHub
   - 如果没有 GitHub 账号，需要先注册一个（免费）
   - 登录 GitHub 后，复制显示的设备代码
   - 粘贴到授权页面
   - 点击 **继续**
   - 授权 HACS 访问你的 GitHub 账号

7. **完成配置**：
   - 等待 HACS 初始化
   - 配置完成后，左侧菜单会出现 **HACS** 选项

⚠️ **如果跳转 URL 包含 `homeassistant.local`**：
- 手动将地址栏中的 `homeassistant.local` 改为 `localhost`
- 按回车刷新页面

## 使用 HACS

### 安装集成

1. 点击左侧菜单的 **HACS**

2. 点击 **集成**

3. 点击右下角 **+ 浏览并下载存储库**

4. 搜索你想要的集成（例如：Xiaomi Home）

5. 点击集成名称

6. 点击 **下载**

7. 选择版本（通常选最新版）

8. 点击 **下载**

9. **重启 Home Assistant**：
   ```bash
   docker-compose restart homeassistant
   ```

10. 进入 **设置** > **设备与服务** > **+ 添加集成** 搜索并配置刚安装的集成

### 安装主题

1. 在 HACS 中点击 **前端**

2. 点击右下角 **+ 浏览并下载存储库**

3. 搜索主题名称

4. 下载并应用

## 常见问题

### Q: 安装脚本失败？

**错误**：`wget: command not found`

**解决方案**：
```bash
# 进入容器
docker exec -it homeassistant bash

# 安装 wget
apk add wget

# 重新运行安装脚本
wget -O - https://get.hacs.xyz | bash -

exit
```

### Q: GitHub 授权失败？

**解决方案**：
1. 确保你有 GitHub 账号
2. 检查网络连接
3. 尝试在浏览器无痕模式下授权
4. 清除浏览器缓存后重试

### Q: HACS 没有出现在集成列表？

**解决方案**：
1. 确认安装脚本成功执行
2. 重启容器：`docker-compose restart homeassistant`
3. 等待 1-2 分钟
4. 刷新浏览器页面
5. 检查日志：`docker-compose logs homeassistant | grep -i hacs`

### Q: 下载集成后找不到？

**解决方案**：
1. 确认已重启 Home Assistant
2. 在"设置" > "设备与服务"中搜索集成名称
3. 有些集成需要手动添加，不会自动出现

### Q: 如何更新 HACS？

HACS 会自动检测更新，在 HACS 界面会显示更新提示。点击更新按钮即可。

### Q: 如何卸载 HACS？

```bash
# 进入容器
docker exec -it homeassistant bash

# 删除 HACS 目录
rm -rf /config/custom_components/hacs

# 退出容器
exit

# 重启
docker-compose restart homeassistant
```

然后在 Home Assistant 中删除 HACS 集成。

## 推荐的社区集成

安装 HACS 后，推荐安装以下集成：

### 米家设备
- **Xiaomi Home** - 完整的米家设备支持，支持扫码登录

### 其他实用集成
- **Node-RED** - 可视化自动化编辑器
- **File Editor** - 在 Web 界面编辑配置文件
- **Studio Code Server** - 完整的 VS Code 编辑器
- **Mushroom Cards** - 美观的卡片组件

### 主题
- **iOS Dark Mode Theme** - iOS 风格深色主题
- **Google Dark Theme** - Google 风格主题
- **Noctis** - 简洁的深色主题

## 安全建议

1. **GitHub Token 安全**：
   - HACS 使用的 GitHub token 只有读取权限
   - 不会访问你的私有仓库
   - 可以随时在 GitHub 设置中撤销授权

2. **只安装可信的集成**：
   - 查看集成的 GitHub 星标数
   - 阅读用户评价
   - 检查最后更新时间

3. **定期更新**：
   - HACS 会提示集成更新
   - 建议及时更新以获取安全修复

## 参考资源

- [HACS 官方文档](https://hacs.xyz/)
- [HACS GitHub](https://github.com/hacs/integration)
- [Home Assistant 社区论坛](https://community.home-assistant.io/)

---

**安装完成后，继续查看 [Xiaomi 配置指南](XIAOMI_SETUP.md) 安装 Xiaomi Home 集成。**
