---
name: ima-diary-auto
description: "当用户说记一下、记到日记、记录一下、帮我记住、写到IMA、记到笔记里、实时记录、当备忘录用或任何表达请把我说的内容存到 IMA 日记意图时使用此 skill。也适用于用户希望将当前对话持续记录到 IMA 日记的场景（实时记录模式）。依赖 ima-skill 下的 ima_api.cjs 调用 IMA OpenAPI。"
agent_created: true
---

# IMA 实时日记记录 Skill

## 日记结构

每篇日记分为两部分：

```
# YYYY年M月D日 日记

## Part 1：实时记录
（白天 AI 实时写入的所有对话内容）
...

## Part 2：每日复盘
（每天晚上 22:00 自动生成）
...
```

**Part 1** 由 AI 在对话中实时追加，**Part 2** 由自动化在每晚 22:00 生成。

## 触发场景

当用户的输入匹配以下任一意图时，**立即加载本 skill** 并遵循以下指令：

- "记一下"、"记到日记"、"记录一下"、"帮我记住"
- "写到IMA"、"记到笔记"、"同步到日记"
- "实时记录"、"当备忘录用"、"我说话你帮我记"
- 用户明确要求对话内容实时写入 IMA 笔记/日记
- 用户说"来吧"、"开始记"、"继续记"等确认开始记录的话（延续之前的记录模式）

**注意：** 本 skill 只负责"日记场景"——创建和追加当天日记。涉及搜索/修改已有笔记等其他笔记操作，仍使用 `ima-skill:notes`。

## 前置依赖

- IMA API 凭证已配置在 `~/.config/ima/client_id` 和 `~/.config/ima/api_key`
- IMA skill 已安装，`ima_api.cjs` 位于 `~/.workbuddy/skills/ima-skill/ima_api.cjs`
- macOS 环境需在命令前加 `NODE_OPTIONS=""` 避免冲突

IMA API 调用命令模板：

```bash
NODE_OPTIONS="" node ~/.workbuddy/skills/ima-skill/ima_api.cjs '<api_path>' '<json_body>'
```

## 核心工作流

### 第一步：查找或创建当天日记

以"YYYY年M月D日 日记"（例如"2026年5月22日 日记"）为标题，搜索 IMA 笔记列表：

```bash
NODE_OPTIONS="" node ~/.workbuddy/skills/ima-skill/ima_api.cjs 'openapi/note/v1/list_note' '{"folder_id":"", "sort_type":0, "cursor":"", "limit":20}'
```

**判断逻辑**：
- 遍历返回的 `data.note_book_list`，检查 `title` 是否匹配当天日记标题
- 如果找到 → 记录该 `note_id`，后续用 `append_doc` 追加
- 如果未找到 → 用 `import_doc` 新建：

```bash
NODE_OPTIONS="" node ~/.workbuddy/skills/ima-skill/ima_api.cjs 'openapi/note/v1/import_doc' '{"content_format": 1, "content": "# YYYY年M月D日 日记"}'
```

**注意：** `import_doc` 一次只创建一个笔记基础结构，不要一次性写入过多内容。创建成功后从返回中取 `note_id`。

### 第二步：实时追加内容

每次用户发送新消息后，向当天日记追加内容。格式如下（Markdown）：

```markdown

---

**HH:MM 用户说：**
> 用户的原文

**AI 处理 / 思考：**
AI 的核心处理结果或对用户想法的理解
```

追加命令：

```bash
NODE_OPTIONS="" node ~/.workbuddy/skills/ima-skill/ima_api.cjs 'openapi/note/v1/append_doc' '{"note_id": "<上一步获取的note_id>", "content_format": 1, "content": "\n\n---\n\n**内容块**\n\n详细内容..."}'
```

### 第三步：持续记录模式

当用户激活本 skill 后，**区分两种模式**：

**模式A — 单次记录（默认）**：用户说"记一下"后接着说了具体内容，只记录这一次。
- 例如："记一下，明天下午三点开会" → 追加一句，不开启持续模式

**模式B — 持续记录模式**：用户明确表示要"当备忘录用"、"实时记录"、"我都记着"等。
- 同一对话中后续每条消息都继续追加，直到用户说"不记了"、"停"、"到此为止"
- 每次回复用户前，先将用户原文及关键处理写入 IMA 日记
- 内容按时间顺序排列，形成天然的时间线

**⚠️ 防重复规则：** 同一个用户消息不要在日记中出现两次。如果前一轮已追加，下一轮不要再追加同一内容。

## 内容写入规则

### 写什么
- **用户的原文优先** — 不要过度总结或改写
- 括号备注 AI 的核心判断/建议，一两句话即可
- 如果用户说了多个点，按点分行记录

### 不写什么
- 工具调用过程、调试信息、技术报错
- 重复性的问候、确认性对话（"好了"、"行"、"嗯"）
- 与记录无关的闲聊

### 内容冗余处理
- 如果内容超长（`100009` 错误码），拆分为多次 `append_doc` 调用
- 不要一次性追加过量内容

## Part 2：每日复盘（22:00 自动执行）

每晚 22:00，自动化任务触发复盘流程。自动化提示词如下：

**步骤：**
1. 读取今天 IMA 日记（Part 1 内容）：
```bash
NODE_OPTIONS="" node ~/.workbuddy/skills/ima-skill/ima_api.cjs 'openapi/note/v1/get_doc_content' '{"note_id": "<当天日记ID>", "target_content_format": 0}'
```

2. 分析当天全部记录，生成 Part 2 复盘内容，追加到日记末尾：

```bash
NODE_OPTIONS="" node ~/.workbuddy/skills/ima-skill/ima_api.cjs 'openapi/note/v1/append_doc' '{"note_id": "<当天日记ID>", "content_format": 1, "content": "...Markdown格式复盘内容..."}'
```

**Part 2 复盘格式（追加到日记末尾，前面加一个分隔标题）：**

```markdown

---

## Part 2：每日复盘（22:00）

### 今日关键主题
- 主题1：一句话概括
- 主题2：一句话概括

### 核心洞察
- 洞察1
- 洞察2

### 待办 / 待跟进
- [ ] 事项1
- [ ] 事项2

### 明日建议
- 建议1
- 建议2
```

**复盘原则：**
- 通读 Part 1 全部内容后再下笔
- 不要重复 Part 1 的内容，而是提炼和总结
- 关键洞察要指向行动——"这意味着什么？下一步应该做什么？"
- 如果当天没有记录（空日记），写一条简短说明即可，不要编造内容
- 待办项直接写入工作区记忆 `MEMORY.md` 的"当前关注"部分，保持同步

## 多轮对话中的行为

在同一个对话中多次加载本 skill 时（用户继续发消息），**承接之前的记录状态**：

1. 不需要重新创建日记——直接使用当天已有的日记 `note_id`
2. 不用再次"查找当天日记"——之前步骤中已经获取了 `note_id`
3. 直接进入"追加内容"步骤
4. 如果怀疑日记笔记被删除或笔记 ID 失效，重新执行"查找当天日记"步骤

## 常见错误处理

| 现象 | 原因 | 处理方式 |
|------|------|----------|
| `code: 51` | `limit` 超出范围 | 确保 `limit` ≤ 20 |
| `code: 100009` | 内容超限 | 拆分为多次 `append_doc` |
| `NODE_OPTIONS` 报错 | macOS 环境变量冲突 | 命令前加 `NODE_OPTIONS=""` |
| 找不到日记笔记 | 被删除或 ID 失效 | 重新 `list_note` 搜索当天日记 |
| `code: 20004` | API 凭证失效 | 检查 `~/.config/ima/client_id` 和 `api_key` |

## 本 skill 不负责的场景

- **搜索已有笔记** → 用 `ima-skill:notes`
- **编辑/修改已写入的日记内容** → IMA 中手动编辑
- **删除日记** → IMA 中手动删除
- **上传文件到 IMA 知识库** → 用 `ima-skill:knowledge-base`
- **非日记类笔记操作** → 用 `ima-skill:notes`
