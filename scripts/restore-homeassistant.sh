#!/bin/bash
# Home Assistant 恢复脚本（支持 Core 和 Docker）

set -e

BACKUP_FILE="$1"

echo "======================================"
echo "Home Assistant 恢复"
echo "======================================"
echo ""

# 检查参数
if [ -z "$BACKUP_FILE" ]; then
    echo "用法: $0 <backup_file>"
    echo ""
    echo "示例:"
    echo "  $0 ~/homeassistant-backups/ha_backup_20231202_100000.tar.gz"
    echo ""
    echo "可用备份:"
    ls -lh ~/homeassistant-backups/*.tar.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'
    exit 1
fi

# 检查备份文件
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 错误: 备份文件不存在: $BACKUP_FILE"
    exit 1
fi

echo "✓ 备份文件: $BACKUP_FILE"
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo "  文件大小: $BACKUP_SIZE"
echo ""

# 验证备份文件
echo "✓ 验证备份文件..."
if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    echo "  备份文件完整性验证通过"
else
    echo "❌ 错误: 备份文件损坏或格式不正确"
    exit 1
fi
echo ""

# 显示备份内容
echo "✓ 备份内容:"
tar -tzf "$BACKUP_FILE" | head -20 | sed 's/^/  /'
TOTAL_FILES=$(tar -tzf "$BACKUP_FILE" | wc -l)
if [ $TOTAL_FILES -gt 20 ]; then
    echo "  ... 共 $TOTAL_FILES 个文件"
fi
echo ""

# 检测安装类型
if [ -d "./config" ]; then
    # Docker 安装
    CONFIG_DIR="./config"
    INSTALL_TYPE="Docker"
elif [ -d "$HOME/.homeassistant" ]; then
    # Core 安装
    CONFIG_DIR="$HOME/.homeassistant"
    INSTALL_TYPE="Core"
else
    echo "❌ 错误: 未找到 Home Assistant 配置目录"
    echo ""
    echo "请确保:"
    echo "  - 在项目目录中运行此脚本（Docker 安装）"
    echo "  - 或者 Core 配置存在于 ~/.homeassistant"
    exit 1
fi

echo "✓ 检测到安装类型: $INSTALL_TYPE"
echo "✓ 配置目录: $CONFIG_DIR"
echo ""

# 确认恢复
echo "⚠️  警告: 此操作将覆盖现有配置！"
echo ""
read -p "是否继续恢复? (yes/N): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "取消恢复"
    exit 0
fi
echo ""

# 停止服务
echo "✓ 停止 Home Assistant 服务..."
if [ "$INSTALL_TYPE" = "Docker" ]; then
    if docker-compose ps | grep -q "homeassistant"; then
        docker-compose down
        echo "  Docker 容器已停止"
    else
        echo "  Docker 容器未运行"
    fi
else
    if launchctl list | grep -q "com.homeassistant.server"; then
        launchctl stop com.homeassistant.server 2>/dev/null || true
        sleep 3
        echo "  Core 服务已停止"
    else
        echo "  Core 服务未运行"
    fi
fi
echo ""

# 备份当前配置
if [ -d "$CONFIG_DIR" ]; then
    CURRENT_BACKUP="$CONFIG_DIR/backup_before_restore_$(date +%Y%m%d_%H%M%S)"
    echo "✓ 备份当前配置..."
    mkdir -p "$CURRENT_BACKUP"
    cp -r "$CONFIG_DIR"/*.yaml "$CURRENT_BACKUP/" 2>/dev/null || true
    cp -r "$CONFIG_DIR/.storage" "$CURRENT_BACKUP/" 2>/dev/null || true
    echo "  当前配置已备份到: $CURRENT_BACKUP"
    echo ""
fi

# 恢复备份
echo "✓ 恢复备份..."
mkdir -p "$CONFIG_DIR"
tar -xzf "$BACKUP_FILE" -C "$CONFIG_DIR"

if [ $? -eq 0 ]; then
    echo "  备份恢复成功"
else
    echo "❌ 恢复失败"
    exit 1
fi
echo ""

# 验证恢复的文件
echo "✓ 验证恢复的文件..."
REQUIRED_FILES=("configuration.yaml" "secrets.yaml")
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$CONFIG_DIR/$file" ]; then
        echo "  ✓ $file"
    else
        echo "  ❌ $file 缺失"
    fi
done
echo ""

# 启动服务
echo "✓ 启动 Home Assistant 服务..."
if [ "$INSTALL_TYPE" = "Docker" ]; then
    docker-compose up -d
    echo "  Docker 容器已启动"
else
    if [ -f "$HOME/Library/LaunchAgents/com.homeassistant.server.plist" ]; then
        launchctl start com.homeassistant.server 2>/dev/null || true
        sleep 5
        
        if launchctl list | grep -q "com.homeassistant.server"; then
            echo "  Core 服务已启动"
        else
            echo "  ⚠️  服务启动失败，请手动启动"
        fi
    else
        echo "  ⚠️  服务未配置，请手动启动 Home Assistant"
    fi
fi
echo ""

echo "======================================"
echo "✓ 恢复完成！"
echo "======================================"
echo ""
echo "安装类型: $INSTALL_TYPE"
echo ""
echo "下一步:"
echo "1. 等待 Home Assistant 启动（约 30-60 秒）"
echo "2. 访问: http://localhost:8123"
echo "3. 检查配置和集成是否正常"
echo ""
if [ "$INSTALL_TYPE" = "Docker" ]; then
    echo "查看日志:"
    echo "  docker-compose logs -f homeassistant"
else
    echo "查看日志:"
    echo "  tail -f ~/.homeassistant/home-assistant.log"
fi
