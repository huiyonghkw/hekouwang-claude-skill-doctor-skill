# Changelog

本项目遵循 [语义化版本](https://semver.org/lang/zh-CN/)。

## [1.3.0] - 2026-07-15

**版本号说明**：本次内容即原定的 1.2.0（见下方 Changed/Added），因发布事故改号为 1.3.0——
ClawHub 上 `hekouwang-claude-skill-doctor-skill` 这个 slug 的 1.2.2 曾被误发成 **md-doctor 的内容**
（check.py 与 md-doctor 逐字节相同、测试夹具是 `CLAUDE.md` 而非 `SKILL.md`），
真正的 skill-doctor 从未上架。需发一个高于 1.2.2 的版本才能把 latest 拨正，故跳到 1.3.0。
误发的 1.2.2 已从该 slug 永久删除。

### Fixed
- **ClawHub 发布事故更正**：`hekouwang-claude-skill-doctor-skill@1.2.2` 实为 md-doctor，已删除；
  本版是首个真正上架 ClawHub 的 Agent Skill 体检器。
- **发布纪律**：以后 `clawhub skill publish` **一律显式传 `--version`**——
  ClawHub 不读 SKILL.md 的 `version`，只在线上版本上 +1（实测会把本地 1.2.2 发成 1.1.3、
  本地 1.1.0 发成 0.1.2，即**降级**）。自动推断不可信。

拿真数据校准步骤 2b 的 SkillSpector。全量扫 7 个 `hekouwang-*` skill、逐条翻源码核实，
结论推翻 1.1.0 的乐观假设：**对自研 skill 它 100% 误报**，且**分数完全不可信**。
2b 从"可选加跑的安全维"收紧为"只对外来 skill 跑的入库审查"。

### Changed
- **2b 定位收紧：只对"别人写的、要装进来的" skill 跑。** 7 个自研 skill 全扫、逐条翻源码，
  无一为真。自研 skill 改走**回归检测**（存基线 → 只看 NEW），不再全量看告警。
- **新增铁律「分数不是门禁，只看条目 + 翻源码」。** `Score/Severity` 是逐条**累加**的：
  yandu-deck / iterm2 / cc-prod 三个判 `100/100 CRITICAL · DO NOT INSTALL`，
  但报告里**一条 CRITICAL 发现都没有**——纯粹是十几条 MEDIUM/HIGH 累加撞顶。
  且评分随版本通胀：content-factory 代码一行没改，v2.3.5 `19/100 SAFE` → v2.3.13 `40/100 CAUTION`。
- **推翻 1.1.0 的「低可信度才是误报」说法**：95% 高可信度的照样是误报。改为附**高置信度误报样本表**：
  `rm -f "$写死路径"` → `TM1` 95%；`subprocess.run([...], check=True)` 硬编码列表 →
  `OH1 Unvalidated Output Injection` 95% + `AST4`（其 remediation 建议的恰恰就是这个写法）；
  docstring 写"本脚本**绝不读取** .env/*.key" → `PE3 Credential Access`；
  字体文件名列表 → `MP2 Context Window Stuffing`；中文 frontmatter → `P2 Hidden Instructions` 21%；
  中文触发词 → `AS3 Mixed script`。

### Added
- **rsync `--exclude` 顺序坑**：必须排在 `--include='*/'` 前面（rsync 首次匹配生效，
  否则 `*/` 先吃掉 `.venv/`，整个 site-packages 被当自己的代码扫）。实测 stock-data-reader 264M→176K。
- **SOCKS 代理绕法**：代理下扫描直接崩（`'socksio' package is not installed`），
  需 `env -u ALL_PROXY -u all_proxy -u HTTPS_PROXY -u https_proxy`。OSV.dev 连不上只降级静态库，不影响结论。
- **`--baseline` 正确用法 + 反例**：`fingerprints` 按「路径+内容 hash」锁定、只对同一 skill 生效；
  能跨 skill 的 glob `rules`（如 `id: "TM1"`）**恰恰不能在扫外来 skill 时开**——
  同一规则在自研 `rm` 上是误报、在恶意 skill 里可能是真的，全局关掉等于拆探头。
- content-factory / yandu-deck / stock-data-reader 三个常改的 skill 各存一份归零基线
  （`.skillspector-baseline.yaml`，A/B 验证：yandu-deck `100 CRITICAL DO_NOT_INSTALL` → `0 LOW SAFE`）。
- 记录唯一有信号的结构性告警 **LP1「代码有 network/env/shell 能力但没声明权限」**（7 个中 5 个命中）——
  不是漏洞，与 `check.py` 自检的「未声明 allowed-tools」指向同一缺口。

## [1.1.0] - 2026-06-24

接入外部安全扫描、消化业界 skill 写作最佳实践，扩展体检维度。

### Added
- **工作流新增步骤 2b · 深度安全扫描（可选）**：叠加 [NVIDIA SkillSpector](https://github.com/NVIDIA/skillspector)，
  覆盖提示注入 / 数据外泄 / 隐藏指令 / 供应链 / 过度授权 / MCP 越权等 68 类模式，
  补 `check.py` #0 密钥正则之外的深度安全维。含实战铁律：**只扫逻辑文件、别扫 assets**
  （直接扫会把字体/图片二进制当代码，刷出几十条假 `TM1 Tool Parameter Abuse`）；
  低可信度（<30%）`Hidden Instructions` 多是中文/零宽字符误报，人工复核。
- **评分维度 #8 触发方式匹配（model vs user invoked）**：只靠人手敲名字触发的 skill
  应设 `disable-model-invocation: true`，省掉每轮 `description` 的 context load。
- **`references/skill-writing-vocab.md`**：消化 mattpocock/skills 的 *writing-great-skills*，
  把"好 skill"的判据沉淀成可命名的诊断词汇——两种载荷（context/cognitive load）、
  信息阶梯、branch 拆分测试、完成判据（防 premature completion）、no-op 测试、
  sediment/sprawl/duplication 失败模式、leading word。出报告时用这些词点破问题。

### Changed
- **#10a 锐化为 no-op 测试**：判据明确为「这段相对模型默认行为改变了什么？没有就删」，
  比原先"别替模型补它已经会的"更可操作。

## [1.0.2] - 2026-06-22

实战体检三个品牌 skill 时暴露的机检缺陷修复（dogfooding）：

### Fixed
- **#7 allowed-tools 兼容逗号字符串**：原先只认 YAML 列表（`- a` / `[a,b]`），
  把官方 frontmatter 标准的逗号字符串写法（`allowed-tools: Bash, Read, Write`）
  误判为「未声明」。现在两种写法都解析、非空即 PASS。

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
