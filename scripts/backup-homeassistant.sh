#!/bin/bash
# Home Assistant 备份脚本（支持 Core 和 Docker）

set -e

BACKUP_DIR="$HOME/homeassistant-backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/ha_backup_$DATE.tar.gz"

echo "======================================"
echo "Home Assistant 备份"
echo "======================================"
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

# 创建备份目录
mkdir -p "$BACKUP_DIR"
echo "✓ 备份目录: $BACKUP_DIR"
echo ""

# 显示将要备份的内容
echo "✓ 备份内容:"
echo "  - 配置文件 (*.yaml)"
echo "  - 集成配置 (.storage/)"
echo "  - 自定义组件 (custom_components/)"
echo "  - 主题 (themes/)"
echo ""

# 创建备份
echo "✓ 创建备份..."
cd "$CONFIG_DIR"

# 备份文件列表
FILES_TO_BACKUP=(
    "configuration.yaml"
    "secrets.yaml"
    "automations.yaml"
    "scripts.yaml"
    "scenes.yaml"
    "groups.yaml"
    "customize.yaml"
    ".storage"
)

# 可选备份（如果存在）
OPTIONAL_FILES=(
    "custom_components"
    "themes"
    "www"
    "blueprints"
)

# 构建 tar 命令
TAR_FILES=""
for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -e "$file" ]; then
        TAR_FILES="$TAR_FILES $file"
    fi
done

for file in "${OPTIONAL_FILES[@]}"; do
    if [ -e "$file" ]; then
        TAR_FILES="$TAR_FILES $file"
    fi
done

# 创建压缩包
tar -czf "$BACKUP_FILE" $TAR_FILES 2>/dev/null

if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✓ 备份创建成功"
    echo ""
    echo "======================================"
    echo "✓ 备份完成！"
    echo "======================================"
    echo ""
    echo "安装类型: $INSTALL_TYPE"
    echo "备份文件: $BACKUP_FILE"
    echo "文件大小: $BACKUP_SIZE"
    echo ""
    echo "⚠️  重要提示:"
    echo "  - 备份包含敏感信息（密码、API 密钥等）"
    echo "  - 请妥善保管备份文件"
    echo "  - 建议定期备份到外部存储"
    echo ""
    echo "恢复命令:"
    echo "  ./scripts/restore-homeassistant.sh $BACKUP_FILE"
else
    echo "❌ 备份失败"
    exit 1
fi

# 列出所有备份
echo ""
echo "现有备份:"
ls -lh "$BACKUP_DIR"/*.tar.gz 2>/dev/null | awk '{print "  " $9 " (" $5 ")"}'

# 清理旧备份（保留最近 10 个）
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)
if [ $BACKUP_COUNT -gt 10 ]; then
    echo ""
    echo "✓ 清理旧备份（保留最近 10 个）..."
    ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +11 | xargs rm -f
fi
