# ima-diary-auto 安装指南

> 一句话：把 WorkBuddy 手机聊天框变成自动日记本。说"记一下"，AI 自动写进 IMA。

---

## 前置条件

| 条件 | 说明 |
|------|------|
| IMA 桌面端 | 安装腾讯 IMA（ima.qq.com） |
| IMA API 凭证 | 在 IMA 设置中获取 clientId 和 apiKey |
| WorkBuddy | 已安装并登录 |

## 安装步骤（3 步）

### 1. 配置 IMA API 凭证

在终端执行：

```bash
mkdir -p ~/.config/ima
echo "你的clientId" > ~/.config/ima/client_id
echo "你的apiKey" > ~/.config/ima/api_key
```

### 2. 安装依赖 Skill（ima-skill）

如果你还没装 ima-skill，先在 WorkBuddy 中安装它（Skill 市场搜索"ima"）。

### 3. 安装本 Skill

把 `ima-diary-auto.zip` 拖入 WorkBuddy 的 Skill 管理界面，或使用导入功能。

安装完成后，会在 `~/.workbuddy/skills/ima-diary-auto/` 下看到 SKILL.md。

---

## 使用方法

### 模式 A：单次记录

在 WorkBuddy 对话中说：

> 记一下，明天下午三点开会

→ AI 把这句话写入今天 IMA 日记，结束。

### 模式 B：持续记录

说：

> 从今天开始当备忘录用，我说话你帮我记

→ 之后每条消息自动写入 IMA 日记，直到你说"停"。

---

## 日记结构

每天自动创建一篇日记，标题 `2026年5月22日 日记`，分为两部分：

- **Part 1**：白天实时记录（你说的话 + 时间戳）
- **Part 2**：每晚 22:00 自动复盘（关键主题、核心洞察、待办、明日建议）

Part 2 需要配合自动化任务使用（见下方"进阶配置"）。

---

## 进阶配置（可选）

想要每天晚上 22:00 自动复盘？在 WorkBuddy 中创建一个自动化：

- 调度：每天 22:00
- 工作目录：你的 WorkBuddy 项目路径
- 提示词内容请参考 SKILL.md 中的"Part 2 复盘"章节

---

## 常见问题

**Q: 报 "missing credentials" 错误？**
→ 检查 `~/.config/ima/client_id` 和 `api_key` 是否存在且正确。

**Q: 报 "NODE_OPTIONS" 错误？**
→ macOS 特有问题，Skill 已自动处理（命令前加了 NODE_OPTIONS=""）。

**Q: 日记写进去了但在 IMA 里看不到？**
→ 打开 IMA 桌面端 → 笔记列表 → 找到当天日记。标题格式 "YYYY年M月D日 日记"。

---

## 适用场景

- 碎片想法随时记（不用打开任何 App）
- 微信式聊天 → 自动变成日记
- 个人知识积累 + 日终复盘
