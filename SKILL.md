---
name: ima-sync
description: 将AI生成的文档类产出（报告、分析、文档、总结、纪要等）自动同步到腾讯ima笔记，并保持丰富排版。当用户说保存到笔记、同步到ima、记到笔记里、导出到笔记、生成报告并保存、整理成笔记等时触发，也可在完成文档类任务后主动询问用户是否需要同步。
---

# IMA Sync - 文档自动同步到笔记

## 目的

当 AI 完成文档类任务时，自动将内容同步到用户的腾讯 ima 笔记，保持排版美观、格式丰富。

## 触发时机

以下场景**必须主动询问**用户是否需要同步到 ima 笔记：

1. **完成文档类任务后**：
   - 报告、分析文档、研究报告、市场报告
   - 会议纪要、工作总结、项目文档
   - 数据分析、调研报告、对比分析
   - 规划方案、提案、PPT 内容

2. **用户明确要求**：
   - "保存到笔记"、"同步到 ima"
   - "记到笔记里"、"导出到笔记"
   - "生成报告并保存"、"整理成笔记"

## 交互流程

### 步骤 1：询问同步意愿

完成文档后，主动询问：

> "这份报告已生成完毕。需要我同步到您的 ima 笔记吗？
> - **创建新笔记**：新建一篇笔记保存这份内容
> - **追加到已有笔记**：将内容追加到指定的已有笔记末尾"

### 步骤 2：根据用户选择执行

**用户选择"创建新笔记"**：
1. 调用 `ima_api.cjs` 的 `import_doc` 接口
2. 将完整 Markdown 内容写入笔记
3. 返回笔记创建成功提示，包含笔记标题

**用户选择"追加到已有笔记"**：
1. 先询问用户笔记名称，或搜索已有笔记
2. 调用 `append_doc` 接口追加内容
3. 返回追加成功提示

### 步骤 3：格式化内容（关键）

为确保笔记排版美观，使用以下 Markdown 格式规范：

```
# 文档标题

> 📅 创建时间 | 📊 文档类型

---

## 摘要

简要描述文档的核心内容和目的。

---

## 核心内容

### 第一部分
内容...

### 第二部分
内容...

---

## 关键要点 / 结论

1. 要点一
2. 要点二
3. 要点三

---

## 附录 / 参考

- 参考资料1
- 参考资料2
```

## API 调用方法

调用 ima API 前需要先设置凭证：

```bash
# 动态获取 skill 目录（兼容 macOS/Linux/WSL）
IMA_SKILL_DIR=""
for dir in ~/.workbuddy/skills/腾讯ima ~/.workbuddy/skills/ima-sync/../腾讯ima; do
  if [ -f "$dir/ima_api.cjs" ]; then
    IMA_SKILL_DIR="$dir"
    break
  fi
done

if [ -z "$IMA_SKILL_DIR" ]; then
  echo "❌ 错误：未找到「腾讯ima」skill 请先安装腾讯ima skill" >&2
  exit 1
fi

OPTS=$(printf '{"clientId":"%s","apiKey":"%s"}' "$IMA_OPENAPI_CLIENTID" "$IMA_OPENAPI_APIKEY")

# 新建笔记
node "$IMA_SKILL_DIR/ima_api.cjs" "openapi/note/v1/import_doc" \
  '{"content_format": 1, "content": "# 标题\n\n正文内容"}' "$OPTS"

# 追加到已有笔记
node "$IMA_SKILL_DIR/ima_api.cjs" "openapi/note/v1/append_doc" \
  '{"note_id": "笔记ID", "content_format": 1, "content": "\n\n## 新增内容\n\n追加的文本"}' "$OPTS"

# 搜索笔记
node "$IMA_SKILL_DIR/ima_api.cjs" "openapi/note/v1/search_note" \
  '{"search_type": 0, "query_info": {"title": "关键词"}, "start": 0, "end": 20}' "$OPTS"
```

## 排版优化指南

### 标题层级
- `#` 一级标题：文档主标题
- `##` 二级标题：主要章节
- `###` 三级标题：子章节
- 避免超过三级标题，保持结构清晰

### 强调与标记
- `**粗体**：强调关键词
- `*斜体*`：次要强调
- `> 引用`：重要引述或摘要
- `- [ ] 待办`：任务清单

### 列表格式
- 无序列表：使用 `•` 或 `-`
- 有序列表：使用 `1.` `2.` `3.`
- 嵌套列表：缩进 2 个空格

### 表格
```
| 列1 | 列2 | 列3 |
|-----|-----|-----|
| 内容 | 内容 | 内容 |
```

### 代码块
```
```语言
代码内容
```
```

### 分割线
使用 `---` 分隔主要章节

## 注意事项

1. **UTF-8 编码**：确保所有字符串字段为合法 UTF-8
2. **本地图片**：笔记 API 不支持本地图片，过滤 `file://` 路径
3. **内容大小**：单次写入有上限，超出时分批追加
4. **隐私保护**：在群聊中只展示标题和摘要，不展示正文
5. **时间戳**：写入时自动添加创建时间

## 凭证配置

如果用户尚未配置 ima 凭证，引导完成配置：

1. 打开 https://ima.qq.com/agent-interface 获取 Client ID 和 API Key
2. 配置凭证：
```bash
mkdir -p ~/.config/ima
echo "your_client_id" > ~/.config/ima/client_id
echo "your_api_key" > ~/.config/ima/api_key
```
