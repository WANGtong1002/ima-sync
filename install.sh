#!/bin/bash
#
# ima-sync 一键安装脚本
# 用法: bash -c "$(curl -sL https://raw.githubusercontent.com/WANGtong1002/ima-sync/main/install.sh)"
#

set -e

REPO_URL="https://raw.githubusercontent.com/WANGtong1002/ima-sync/main"
SKILL_DIR="$HOME/.workbuddy/skills/ima-sync"

echo "📦 正在安装 ima-sync..."

# 1. 下载最新版本
TEMP_DIR=$(mktemp -d)
curl -sL "$REPO_URL/ima-sync.zip" -o "$TEMP_DIR/ima-sync.zip"

# 2. 备份旧版本（如果存在）
if [ -d "$SKILL_DIR" ]; then
    BACKUP_DIR="${SKILL_DIR}.backup.$(date +%Y%m%d%H%M%S)"
    echo "📁 备份旧版本到: $BACKUP_DIR"
    mv "$SKILL_DIR" "$BACKUP_DIR"
fi

# 3. 解压安装
mkdir -p "$HOME/.workbuddy/skills"
unzip -o "$TEMP_DIR/ima-sync.zip" -d "$HOME/.workbuddy/skills/"

# 4. 清理
rm -rf "$TEMP_DIR"

# 5. 检查依赖
if [ ! -d "$HOME/.workbuddy/skills/腾讯ima" ]; then
    echo ""
    echo "⚠️  警告：未检测到「腾讯ima」skill"
    echo "   ima-sync 依赖腾讯ima提供API能力"
    echo "   请先安装：https://ima.qq.com/agent-interface"
    echo ""
fi

echo ""
echo "✅ 安装完成！"
echo ""
echo "📝 下一步："
echo "   1. 配置 IMA 凭证（如果尚未配置）："
echo "      mkdir -p ~/.config/ima"
echo '      echo "你的ClientID" > ~/.config/ima/client_id'
echo '      echo "你的APIKey" > ~/.config/ima/api_key'
echo ""
echo "   2. 重启 WorkBuddy 使 skill 生效"
echo ""
