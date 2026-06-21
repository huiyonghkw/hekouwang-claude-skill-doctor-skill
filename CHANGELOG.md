# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.0.1] - 2026-06-21

实战体检 14 个 skill 时暴露的两个机检缺陷修复（dogfooding）：

### Fixed
- **glob 指针不再误报死链**：`reference/deck-engine-*.html` 这类通配符指针，
  现在用 `glob` 解析、能匹配到真实文件就算存在；`{a,b}` brace 简写跳过不误报。
  （原正则在 `*` 处截断成 `reference/deck-engine-`，当字面路径判死。）
- **指针 / 教学词行号还原为文件绝对行号**：原先报的是正文相对行号（少算了
  frontmatter 行数），定位会偏。`parse_frontmatter` 现返回 `body_offset` 补正。

## [1.0.0] - 2026-06-21

首个版本。给 Agent Skill（SKILL.md）做体检的零依赖检查器。

### 检查项（12 项加权）
- **安全**：SKILL.md 及捆绑文件无硬编码密钥（命中即 FAIL，资损级）。
- **触发**：frontmatter 必填合法（name/description）；description 含「何时用」且 ≤1024 字符。
- **减法**：SKILL.md ≤500 行；长内容下沉 references/（渐进披露）；大段脚本外置 scripts/。
- **可移植**：无硬编码 `/Users/`、`/home/` 绝对路径。
- **取舍**：别替模型补它已会的（教学冗余检测）；allowed-tools 最小化；配套 README/CHANGELOG。

### 特性
- 零依赖（Python3 标准库），文本 + `--json` 双输出，退出码随 FAIL。
- 按重要度加权评分（触发/减法核心项 1.5，标准项 1.0，加内容项 0.6），A/B/C/D 分档。
- 极简零依赖 frontmatter 解析（块标量 / 行内 list / 缩进 list）。
- 密钥扫描双档豁免：指纹型用窄填充表、赋值型用宽占位表，避免误杀真 key。
- 报告口吻与署名沿用「会勇禾口王的AI笔记」品牌人设。
