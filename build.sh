#!/bin/bash
#
# 打包脚本 - 在发布新版本时运行
# 用法: ./build.sh [版本号]
#

VERSION=${1:-$(date +%Y%m%d)}
OUTPUT_DIR="."
SKILL_NAME="ima-sync"

echo "📦 正在打包 ima-sync v$VERSION..."

# 创建临时目录
TEMP_DIR=$(mktemp -d)

# 复制文件（排除 .git 和 build.sh）
rsync -av --exclude='.git' --exclude='build.sh' --exclude='*.sh' \
    . "$TEMP_DIR/$SKILL_NAME/"

# 打包
cd "$TEMP_DIR"
zip -r "$OUTPUT_DIR/${SKILL_NAME}.zip" "$SKILL_NAME/"

# 清理
rm -rf "$TEMP_DIR"

echo "✅ 打包完成: ${SKILL_NAME}.zip"

# 显示文件大小
ls -lh "${SKILL_NAME}.zip"
