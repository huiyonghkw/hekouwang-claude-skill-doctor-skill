---
name: hekouwang-claude-skill-doctor-skill
slug: hekouwang-claude-skill-doctor-skill
displayName: Claude Skill 体检器（SKILL.md Doctor）
summary: Agent Skill lint / SKILL.md doctor / skillspec audit — description 触发、渐进披露、可移植性与 OpenClaw 兼容检查。姊妹工具 md-doctor。
license: MIT-0
homepage: https://github.com/huiyonghkw/hekouwang-claude-skill-doctor-skill
version: 1.5.2
description: >
  会勇禾口王的AI笔记 · Agent Skill（SKILL.md）体检器。检查一个 Claude/Agent Skill 是否
  符合"按需加载的指令包，不是单文件巨石"的最佳实践——评 description 触发质量、SKILL.md
  篇幅、渐进披露（references/ 拆分）、脚本外置、可移植性（无硬编码绝对路径）、安全（无硬编码
  密钥），给出评分卡 + 按优先级的修复建议，并可代为重构。触发：用户说「检查我的 skill /
  SKILL.md 体检 / 这个 skill 规范吗 / claude-skill-doctor / audit skill / lint SKILL.md /
  我的 skill 太长了 / skill 拆分 / 看看我的 skill 合不合规 / skill 对齐官方规范」。
  任何"评估/审查/优化某个 Agent Skill 质量或结构"的请求都应触发。
---

# hekouwang-claude-skill-doctor-skill · Agent Skill 体检器

> **会勇禾口王的AI笔记** 出品 · `@huiyonghkw`
> _不聊 AI 会不会取代你，只聊先用 AI 的人怎么取代你。_

把"Agent Skill 最佳实践"做成一个能跑在任何 skill 上的检查器：机检定量 + 模型定性，
产出评分卡和可落地的修复建议。核心判据一句话——

> **SKILL.md 是模型"决定要不要加载、加载后照着做"的运行时指令包。`description` 决定它何时被唤醒；正文越精简越准；厚重细节要能"按需展开"（references/ 用到再读），而不是每次触发就把全部细节灌进上下文。**
> 一切检查项都从这句推导：这段内容值不值得在 skill 每次触发时都付一次上下文费？能不能下沉到 references/ 用到再读？

### 触发优先 + 减法优先（元判据 · 凌驾全部检查项之上）

Skill 的命脉是两条，权重最高：

1. **触发**：`description` 是模型唯一用来判断"何时唤醒本 skill"的信号。写不清"何时用"，再好的正文也永远不被加载。
2. **减法**：SKILL.md 不是图书馆。模型每代都在变强——你塞进正文的通用写法、框架教程、临时脚本，很快既过时又白占 token。**能下沉 references/ 的下沉，能外置 scripts/ 的外置，模型已经会的删掉。**

所以机检里 **#2 触发 / #3 篇幅 / #4 渐进披露 / #6 可移植 / #10 别替模型补** 权重 1.5；
"加内容"类项（#7 最小工具集、#10 配套文档）缺失只算小扣分——别一边喊"越精简越好"、一边逼作者把 skill 做臃肿。

## 品牌人设（体检报告的口吻 + 署名）

属于 **会勇禾口王的AI笔记**（定位：AI 实战拆解，硬核·具体·可复制；人设：你办公室里第一个把 AI 用明白的同事）。出体检报告时：

- **口吻**：像同事帮你看代码——直给结论、敢泼冷水（"这 description 只写了做什么、不写何时用，等于永远不被触发"），不说客套话。
- **价值化**：修复建议讲"省了什么"（每次触发少灌 100KB 冗余、别人装上不报错、该用时真能被唤醒），不堆术语。
- **署名**：报告结尾固定带 `—— 会勇禾口王的AI笔记 · @huiyonghkw`。命令行 `check.py` 的报告页脚已内置该署名。
- **去 AI 味**：定稿前避开"赋能/打造/至关重要/助力"等词，说人话。

---

## 免费 / 付费边界（重要）

- **免费（开源内核）**：`check.py` 的**文本 / JSON 报告 + 评分**。任何人本地或进 CI 随便跑。
- **免费但要自付 API 钱**：`scripts/trigger_eval.py` 触发力实测（工作流 2c）。脚本本身开源随便用，
  但它每条 query 都真调一次 `claude -p`（约 $0.09–0.15/次），**钱花在用户自己的额度上**。
  所以它是**可选叠加档、不进默认流程**——`check.py` 的零依赖卖点不受影响，不跑也能出完整体检报告。
- **付费（增值）**：**品牌可视化体检报告卡**（评分弧 + 等级带 + 明细分享图），依赖 `hekouwang-content-factory` 的私有品牌字体与版式，不随本仓库分发。
- 一句话口径：**跑检查免费，出"好看的报告图"找 @huiyonghkw。** 外部用户要图时说明是付费增值项，别用系统字体凑一张劣化图糊弄。

---

## 工作流（每次体检按这个顺序）

1. **确认目标**：用户没指明就用当前目录；说了某个 skill 就用那个 skill 目录的绝对路径（目录里要有 `SKILL.md`）。若传进来是 `~/.claude/skills/` 这种父目录，脚本会提示里面有哪些 skill，逐个体检。
2. **跑机检**（确定性层，零依赖）：
   ```bash
   python3 <此skill目录>/check.py <skill目录>
   ```
   - 需要结构化结果时加 `--json`。退出码：有 FAIL → 1，否则 0。
2b. **深度安全扫描（可选 · 外部工具 SkillSpector）**：`check.py` 的 #0 只做密钥正则；当要查**提示注入 / 数据外泄 / 隐藏指令 / 供应链 / 过度授权 / MCP 越权**等 68 类模式时，叠加跑 [SkillSpector](https://github.com/NVIDIA/skillspector)（本机已装：`uv tool install`，需 Python 3.12/3.13）：
   ```bash
   env -u ALL_PROXY -u all_proxy -u HTTPS_PROXY -u https_proxy \
     skillspector scan <纯逻辑副本> --no-llm --format markdown -o report.md
   ```
   - **只对"别人写的、要装进来的" skill 跑。** 自研 skill 扫出来的实测是 100% 误报（2026-07-15 全量验证 7 个 hekouwang-* skill，逐条翻源码，无一为真），跑了只会浪费时间。
   - **自研 skill 只做回归检测。** content-factory / yandu-deck / stock-data-reader 三个（会持续改的）已各存一份归零基线在自己目录的 `.skillspector-baseline.yaml`，改完代码后：
     ```bash
     skillspector scan <纯逻辑副本> --no-llm --baseline <skill目录>/.skillspector-baseline.yaml
     ```
     **冒出来的任何一条都是新的**，值得真翻一眼源码；`--show-suppressed` 看压了什么。基线里的 13/8/4 条已核实为误报（2026-07-15 A/B 验证：yandu-deck `100 CRITICAL DO_NOT_INSTALL` → `0 LOW SAFE`）。改动大到路径/内容 hash 全变时重新 `skillspector baseline <副本> -o …` 存一版。
   - **分数不是门禁，只看条目。** `Score/Severity` 是**逐条累加**出来的：yandu-deck/iterm2/cc-prod 三个都判 `100/100 CRITICAL · DO NOT INSTALL`，但报告里**一条 CRITICAL 发现都没有**——纯粹是十几条 MEDIUM/HIGH 累加撞顶。且评分随版本通胀：content-factory 代码一行没改，v2.3.5 是 `19/100 SAFE`，v2.3.13 变 `40/100 CAUTION`。**永远读条目、翻源码，别信总评。**
   - **铁律：只扫逻辑文件，别扫 assets。** 直接扫会把字体 `.woff2`、PNG 等**二进制当代码**，在字节流里刷出几十条假 `TM1 Tool Parameter Abuse`。先用 rsync 拷纯逻辑副本（只留 `.md/.py/.js/.json/.html/.css/.sh/.txt/.yaml`）。⚠️ **`--exclude` 必须写在 `--include='*/'` 前面**（rsync 首次匹配生效，否则 `*/` 先吃掉 `.venv/`，把整个 site-packages 当你的代码扫）：
     ```bash
     rsync -a --prune-empty-dirs \
       --exclude='.venv/' --exclude='node_modules/' --exclude='.git/' --exclude='__pycache__/' \
       --include='*/' --include='*.md' --include='*.py' --include='*.js' --include='*.json' \
       --include='*.html' --include='*.css' --include='*.sh' --include='*.txt' --include='*.yaml' \
       --exclude='*' <skill目录>/ <副本>/
     ```
     实测 content-factory 141M→1.1M、stock-data-reader 264M→176K。
   - **已知高置信度误报样本**（别被 90%+ 唬住，这些全部核实为假）：`rm -f "$写死的路径"` → `TM1 Tool Parameter Abuse` 95%；`subprocess.run([...], check=True)` 硬编码列表 → `OH1 Unvalidated Output Injection` 95% + `AST4`（它建议的 remediation 恰恰就是这个写法）；docstring 里写"本脚本**绝不读取** .env/*.key" → `PE3 Credential Access`；字体文件名列表 → `MP2 Context Window Stuffing`；中文 frontmatter → `P2 Hidden Instructions`（置信度 21%，全在 `:1`）；中文触发词 → `AS3 Mixed script`。
   - **`--baseline` 的 glob `rules` 别乱开。** `rules: {id: "TM1"}` 能跨 skill 全局压制，但**扫外来 skill 时恰恰不能用**——今天 TM1 在自研 `rm` 上是误报，在恶意 skill 里可能是真的，全局关掉等于拆探头。跨 skill 只压 `path`+`message` 都限定死的具体条目。
   - **代理会让扫描直接崩**：SOCKS 代理下报 `Using SOCKS proxy, but the 'socksio' package is not installed`（同 `词级字幕.py` 那个坑），用上面的 `env -u` 绕开。OSV.dev 连不上只是降级到静态库，不影响结论。
   - 唯一值得看的结构性信号是 **LP1「代码有 network/env/shell 能力但没声明权限」**（7 个自研 skill 中 5 个命中）——不是漏洞，是提醒你 frontmatter 可以补 `allowed-tools`。
   - `--no-llm` 纯静态、免 key；要更准的行为分析再配 LLM provider（`SKILLSPECTOR_PROVIDER` + 对应 key）。结论并进体检报告的安全维，不替代 #0。
2c. **触发力实测（可选 · 要花钱 · 只在怀疑 description 时跑）**：机检 #2 只能看出有没有信号词，
   **判不了写得准不准**——那是本 skill 最大的盲区，因为 description 写不准 = 这个 skill 永远不被唤醒，
   正文写得再好也白搭。要判准不准就得真跑一遍：
   ```bash
   python3 <此skill目录>/scripts/trigger_eval.py \
     --eval-set <你的query集>.json --skill-path <skill目录>
   ```
   把待测 description 装成临时探针 skill，跑 `claude -p` 看模型会不会去调它。跑完即删，不碰已装的 skill。
   - ⭐ **先做基准分辨力自检再信分数**：拿真 description 和一段故意写烂的（"生成内容。"）
     跑同一套 query，**分数分不开就说明判据在当前环境失灵**，此时高分也是噪音。
     实测参考 A=100 / B=50。开发这个脚本时四处配置错误里有三处都表现为"跑通了、只是分数低"——
     不做 A/B 根本发现不了。
   - **读结果分两种失败**：漏触发＝覆盖不够（补场景句和同义说法）；误触发＝写太宽泛（加边界、换具体动作）。
     两种都有＝抓错维度，重写而非打补丁。
   - ⚠️ **要钱**：每条 query 每次采样约 $0.09–0.15，20 条 ×3 次约 $6–9。先用 4–6 条粗筛。
   - query 怎么设计（尤其**负例必须是 near-miss**）、结果不对劲怎么翻原始流、脚本那四处
     不能改回去的坑 → 读 [`references/trigger-eval.md`](references/trigger-eval.md)。
   - **`check.py` 不依赖它**，零依赖那条卖点不受影响；这一档是叠加的，不跑也能出完整体检报告。

3. **定性复核**（机检之上，必须做）：机检是启发式，几项要你**真正读 SKILL.md**再下结论（见下「机检的盲区」）：
   - 通读 `description`，**真的当一次模型**：光看这段，能不能判断"什么请求该唤醒它"？
   - 通读正文：哪些是"模型不可能知道的项目/品牌私有事实"（该留），哪些是"通用写法/框架教程"（该删或下沉）？
   - 若正文很长，看它能不能按"版本/平台/流程"天然切成 references/。
4. **出报告**：先一句话总评 + 分数档位，再用"✓/▲/✗ + 一句话 + 修复建议"逐条列，最后给 **Top 3 最该先改的**（按"花最小力气补最大漏洞"排序）。中文输出。
5. **提出代重构**：问用户要不要直接改（瘦身 SKILL.md、拆 references/、外置 scripts/、把硬路径换成 `~`/相对路径、补 description 触发句）。**得到同意再动文件**，一次改一类、可回退；改完**重跑 `check.py`** 给前后对比分数。

> 不要只把脚本输出原样贴给用户——脚本是线索，你的价值在定性判断 + 具体怎么拆。

---

## 评分标准（12 项 · 也是机检的判分依据）

| # | 检查项 | 合格长什么样 | 不合格信号 |
|---|--------|------------|-----------|
| 0 | **无硬编码密钥（安全红线）** | SKILL.md 及捆绑文件无 key/token/私钥/口令明文 | 出现 `sk-`/`AKIA`/私钥块/`password="..."` → **直接 FAIL**（skill 常被分发，泄露面更大）<br>⚠️ 测试夹具目录（`test/ tests/ fixtures/ golden/ snapshots/`）里的命中判 **WARN 不判 FAIL**——安全基准的假密钥是刻意载荷，误报会把红线变成摆设 |
| 1 | **frontmatter 必填合法** | 有 `name`（小写+连字符 ≤64）+ `description` | 缺 name/description → FAIL；name 含大写/下划线/空格 → WARN |
| 2 | **description 含「何时用」** | 同时写清"做什么 + 何时/触发用"（这是被唤醒的唯一依据） | 只写"做什么"不写"何时用"；或太短没触发信号<br>⚠️ 机检只判"有没有信号词"，判不了准不准 —— 要判准不准走**触发力实测**（工作流 2c） |
| 2b | **description ≤ 1024 字符** | 在上限内，触发稳定 | 超长，可能被截断 |
| 3 | **SKILL.md ≤ 500 行** | 路由器不是图书馆，按需加载越短越准 | >500 行；分版本/分平台/长流程全塞一个文件 |
| 4 | **渐进披露（拆 references/）** | 长内容下沉独立 .md，正文留指针 | 正文很长却没有任何 references 拆分文件 |
| 4b | **指针无死链** | 引用的 `references/*.md` 等带扩展名的捆绑资源真实存在 | 指针指向不存在的文件（按图索骥扑空） |
| 5 | **脚本外置 scripts/** | 确定性代码（构建/截图/合成/转换）是 scripts/ 真文件 | 大段可执行代码内联在正文，每次靠模型重打 |
| 6 | **可移植（无硬编码绝对路径）** | 用 `~`/`$HOME`/相对路径/占位 | 出现硬编码家目录绝对路径——别人装上即失效 |
| 7 | **allowed-tools 最小化** | 声明本 skill 真正需要的工具 | 不声明（继承全部工具，越权面大）——可选项，低权重 |
| 8 | **触发方式匹配（model vs user invoked）** | 只靠人手敲名字触发的 skill 设 `disable-model-invocation: true`（零 context load） | 明明只手动触发，却留着 description 当 model-invoked，每轮白占上下文（详见 references/skill-writing-vocab.md 第二节）——定性项 |
| 10a | **别替模型补它已经会的（no-op 测试）** | 只装项目/品牌私有事实 | 有"语言入门/框架教程/如何使用"这类教学段——判据：**这段相对模型默认行为改变了什么？没有就删**（即 no-op；详见 vocab 第六节） |
| 10b | **配套文档（README+CHANGELOG）** | 对外分发友好 | 缺失——纯自用可忽略，低权重 |
| 11 | **paths / globs 作用域** | 文件专属 skill 声明 glob，减少误触发 | Cursor 2.4+ 可用；未声明 = INFO |
| 12 | **OpenClaw 兼容声明** | 有 scripts/ 或发 ClawHub 时声明 requires/install | 纯指令 skill 可忽略——INFO |

**分档**：A 优秀 ≥85 · B 良好 ≥70 · C 及格 ≥50 · D 建议重构 <50。
（机检：PASS=1 / WARN=0.5 / FAIL=0，INFO 不计分。**按重要度加权**——安全红线 #0 与触发/减法核心项 #1/#2/#3/#4/#6/#10a 权重 1.5，标准项 #2b/#4b/#5/#11 为 1.0，加内容项 #7/#10b/#12 为 0.6。#0 命中按 FAIL 计且资损级，定性总评里应一票顶到「先改这条」。）

---

## 机检的盲区（定性复核时重点纠偏）

脚本只判"机器能确定的"，以下几项**容易误判，必须你读正文定夺**：

- **#2 触发质量**：脚本只看 description 里有没有"当…时/use when"等信号词，**判不了写得准不准**。你要真的当模型读一遍：这段能不能把本 skill 和别的 skill 区分开？会不会该触发时没触发、不该触发时乱触发？
  - ⭐ **这条现在能实测，别停在拍脑袋**：走工作流 2c 的 `scripts/trigger_eval.py`，
    "会不会该触发时没触发、不该触发时乱触发"正好对应输出里的**漏触发 / 误触发**两个计数。
    定性读完有怀疑、或者这个 skill 值得下功夫（常用、要分发、要收费），就跑一轮实测坐实。
    ⚠️ 但**跑之前先做 A/B 基准自检**（真 description vs 一段写烂的），分不开就别信分数。
- **#3/#4 篇幅 vs 图书馆**：长不一定错——有的 skill 天生信息密度高。但"分 3 个视觉版本 × 6 个平台"这种，多半能按维度拆 references/。读结构判断哪些章节是"用到才看"的。
- **#5 脚本外置**：脚本按代码行数/围栏数猜。一段 5 行的示范片段该留正文；一个 80 行的构建/合成脚本该外置。读代码块的"性质"定夺。
- **#10a 别替模型补它已经会的**：脚本按"教程/如何使用/语言入门"措辞猜，**会误伤**——比如正文在写"本项目**自研**流程的用法"（模型确实不知道，该留），或在"反对写教程"。判据是"这段知识模型升级后会不会自动变强"：会→删；不会（项目私有）→留。
- **本 skill 自检会触发 #10a 误报**：因为正文里就列着"教程/如何使用"这些**待检测的黑名单词**——这是元层面的正常现象，定性时直接放行。

> **定性诊断词汇**：做 #2/#3/#4/#8/#10a 这些"机器判不准"的项时，读 [`references/skill-writing-vocab.md`](references/skill-writing-vocab.md)——它把"好 skill"的判据沉淀成可命名的语言（两种载荷、信息阶梯、branch 拆分测试、完成判据防提前收工、no-op 测试、sediment/sprawl/duplication 失败模式、leading word）。出报告时用这些词点破问题，比泛说"太长/有冗余"更准。根判据：**skill 是为榨出确定性而存在，根本美德是「每次走同一套过程」可预测。**

---

## 安全红线（务必遵守）

- **绝不读取密钥文件**：`.env` / `*.key` / `*.pem` / `*secret*` 一律不打开（脚本本身也不读）。
- 体检是只读操作；**任何文件改动都要先说明改哪些、为什么，得到同意再动**。
- 跨语言/跨用途通用——本 skill 不绑定任何具体技术栈或 skill 类型。

---

## 修复动作清单（用户同意后按需执行）

- **拔密钥（最高优先）**：#0 命中时把明文移出 SKILL.md / 捆绑文件，改放 `.env` / 密钥管理器；命中即视为已泄露，提醒轮换并查 git 历史（skill 很可能已 push 到 GitHub）。
- **修触发**：#2 不合格时给 description 补"何时用"句——列典型请求 / 触发词 / 适用场景，让模型判得出何时唤醒。
- **瘦身 + 拆 references/**：#3/#4 不合格时，把 SKILL.md 按「版本/平台/流程」维度抽到 `references/` 下的独立 `.md`，正文回归「精简路由 + 硬规矩 + 索引表」。
- **外置 scripts/**：#5 命中时把确定性脚本抠成 `scripts/` 真文件，正文只留一行调用说明。
- **去硬路径**：#6 命中时把硬编码家目录路径换成 `~` / `$HOME` / 相对路径 / 「此 skill 目录」占位。
- **删教学冗余**：#10a 确认是"教通用写法/框架用法"的删掉——skill 只装模型不可能知道的私有事实。
- **修死链**：#4b 报的死指针——补上缺失文件，或修正/删除指针。
- 改完**重新跑一次 `check.py`** 给前后对比分数。

---

## 落地骨架（建/重写一个 skill 时的推荐结构）

```
my-skill/
├── SKILL.md              # ≤500 行：frontmatter(name+description触发句) + 元判据 + 硬规矩
│                         #          + 一张「做 X → 读 references/Y」索引表（路由，不堆细节）
├── references/           # 渐进披露：按版本/平台/流程拆的专题 .md，用到再读
│   ├── topic-a.md
│   └── topic-b.md
├── scripts/              # 确定性可执行脚本（构建/截图/合成/转换），正文只留指针
├── assets/               # 字体/图片/模板等捆绑资源
├── README.md             # 给人看（分发用）
└── CHANGELOG.md          # 版本记录
```

> SKILL.md 是路由，不是仓库。判据始终是：**这段值不值得每次触发都进上下文？能下沉就下沉。**
