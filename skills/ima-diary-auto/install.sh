#!/bin/bash
# ima-diary-auto 一键安装脚本
# 用法: curl -fsSL <本脚本URL> | bash

set -e

SKILL_DIR="$HOME/.workbuddy/skills/ima-diary-auto"
ZIP_URL="https://raw.githubusercontent.com/WANGtong1002/ima-sync/main/skills/ima-diary-auto/ima-diary-auto.zip"

echo "📦 安装 ima-diary-auto..."

# 检查前置条件
if [ ! -d "$HOME/.workbuddy/skills/ima-skill" ]; then
    echo "⚠️  未检测到 ima-skill，请先安装它（WorkBuddy Skill 市场搜索 ima）"
fi

# 下载并解压
mkdir -p "$SKILL_DIR"
curl -fsSL "$ZIP_URL" -o /tmp/ima-diary-auto.zip
unzip -o /tmp/ima-diary-auto.zip -d "$SKILL_DIR" > /dev/null
rm /tmp/ima-diary-auto.zip

echo "✅ 安装完成！"
echo ""
echo "现在在 WorkBuddy 对话框里说「记一下」就能用了。"
echo "每天日记会自动记录到 IMA，标题格式「2026年5月22日 日记」。"
