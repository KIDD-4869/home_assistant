#!/bin/bash

# Xiaomi 集成连接诊断脚本
# 用于排查 Xiaomi 登录问题

echo "========================================="
echo "Xiaomi 集成连接诊断工具"
echo "========================================="
echo ""

# 检查 Home Assistant 容器是否运行
echo "1. 检查 Home Assistant 容器状态..."
if docker ps | grep -q homeassistant; then
    echo "✅ Home Assistant 容器正在运行"
else
    echo "❌ Home Assistant 容器未运行"
    echo "   请先启动容器：docker-compose up -d"
    exit 1
fi
echo ""

# 检查网络连接
echo "2. 检查网络连接..."
if docker exec homeassistant ping -c 3 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo "✅ 容器可以访问互联网"
else
    echo "❌ 容器无法访问互联网"
    echo "   请检查 Docker 网络配置"
    exit 1
fi
echo ""

# 检查小米服务器连接
echo "3. 检查小米服务器连接..."
echo "   测试中国服务器..."
if docker exec homeassistant ping -c 3 -W 2 account.xiaomi.com > /dev/null 2>&1; then
    echo "✅ 可以连接到 account.xiaomi.com"
else
    echo "⚠️  无法连接到 account.xiaomi.com"
    echo "   这可能导致登录失败"
fi
echo ""

# 检查 DNS 解析
echo "4. 检查 DNS 解析..."
DNS_RESULT=$(docker exec homeassistant nslookup account.xiaomi.com 2>&1)
if echo "$DNS_RESULT" | grep -q "Address:"; then
    echo "✅ DNS 解析正常"
    echo "$DNS_RESULT" | grep "Address:" | tail -1
else
    echo "❌ DNS 解析失败"
    echo "   请检查 Docker DNS 配置"
fi
echo ""

# 检查 Home Assistant 配置
echo "5. 检查 Home Assistant URL 配置..."
if grep -q "external_url" config/configuration.yaml && grep -q "internal_url" config/configuration.yaml; then
    echo "✅ URL 配置已设置"
    grep "external_url\|internal_url" config/configuration.yaml | sed 's/^/   /'
else
    echo "⚠️  未找到 URL 配置"
    echo "   建议在 configuration.yaml 中添加："
    echo "   homeassistant:"
    echo "     external_url: \"http://localhost:8123\""
    echo "     internal_url: \"http://localhost:8123\""
fi
echo ""

# 检查日志中的 Xiaomi 相关错误
echo "6. 检查最近的 Xiaomi 相关日志..."
XIAOMI_LOGS=$(docker-compose logs --tail=100 homeassistant 2>&1 | grep -i xiaomi | grep -i "error\|warning" | tail -5)
if [ -n "$XIAOMI_LOGS" ]; then
    echo "⚠️  发现 Xiaomi 相关错误/警告："
    echo "$XIAOMI_LOGS" | sed 's/^/   /'
else
    echo "✅ 未发现明显的 Xiaomi 错误"
fi
echo ""

# 提供建议
echo "========================================="
echo "诊断完成！"
echo "========================================="
echo ""
echo "常见问题解决方案："
echo ""
echo "1. 登录失败 - 凭据错误："
echo "   • 中国大陆用户必须选择 'cn' 服务器"
echo "   • 使用小米账号（手机号/邮箱）+ 密码"
echo "   • 不要使用微信/QQ 等第三方登录"
echo ""
echo "2. 需要验证码："
echo "   • 在米家 app 中完成验证"
echo "   • 然后在 Home Assistant 中重试"
echo ""
echo "3. URL 重定向错误："
echo "   • 将地址栏中的 homeassistant.local 改为 localhost"
echo ""
echo "4. 账号被锁定："
echo "   • 等待 15-30 分钟"
echo "   • 在米家 app 中成功登录一次"
echo ""
echo "详细排查步骤请查看：docs/XIAOMI_SETUP.md"
echo ""
