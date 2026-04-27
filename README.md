# ima-sync - 文档自动同步到腾讯ima笔记

将 AI 生成的报告、分析、总结等文档类产出自动同步到腾讯 ima 笔记，保持 Markdown 丰富排版。

## 🚀 一键安装

```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/WANGtong1002/ima-sync/main/install.sh)"
```

## ✨ 功能特点

- ✅ 自动保存 AI 生成的文档到 ima 笔记
- ✅ 支持创建新笔记或追加到已有笔记
- ✅ 自动格式化排版（标题层级、表格、代码块等）
- ✅ 支持追加内容到已有笔记末尾

## 📋 前置依赖

**必须先安装「腾讯ima」skill**：

1. 打开 https://ima.qq.com/agent-interface 获取 Client ID 和 API Key
2. 配置凭证：
```bash
mkdir -p ~/.config/ima
echo "你的ClientID" > ~/.config/ima/client_id
echo "你的APIKey" > ~/.config/ima/api_key
```

## 📖 使用方式

### AI 主动询问
完成报告、分析等文档类任务后，AI 会询问"是否同步到笔记"

### 用户主动要求
- "保存到笔记"
- "同步到 ima"
- "记到笔记里"
- "导出到笔记"

### 选择模式
- **创建新笔记**：新建一篇笔记保存内容
- **追加到已有笔记**：将内容追加到指定笔记末尾

## 📝 笔记格式示例

```markdown
# 文档标题

> 📅 2026-04-27 | 📊 分析报告

---

## 摘要

简要描述文档的核心内容...

---

## 核心内容

### 第一部分
内容...

### 第二部分
内容...

---

## 关键要点

1. 要点一
2. 要点二
3. 要点三
```

## 🔧 手动安装

1. 下载 [ima-sync.zip](ima-sync.zip)
2. 解压并将 `ima-sync` 目录复制到 `~/.workbuddy/skills/`
3. 确保已安装「腾讯ima」skill
4. 重启 WorkBuddy

## 📦 发布新版本

```bash
./build.sh [版本号]
git add .
git commit -m "release: v1.0.1"
git tag v1.0.1
git push && git push --tags
```

## 📄 版本历史

- **v1.0.1**：修复路径硬编码问题，支持跨环境安装
- **v1.0.0**：初始版本

## ⚠️ 注意事项

1. 笔记 API 不支持本地图片，请使用网络图片链接
2. 单次写入有大小上限，超出时分批追加
3. 凭证配置在 `~/.config/ima/` 目录
