# hekouwang-claude-skill-doctor-skill

> **会勇禾口王的AI笔记** 出品 · `@huiyonghkw`
> 不聊 AI 会不会取代你，只聊先用 AI 的人怎么取代你。

给 **Agent Skill（SKILL.md）** 做体检的工具。把"Skill 是按需加载的指令包、不是单文件巨石"
这条最佳实践，做成一个能跑在任何 skill 上的检查器：机检定量 + 模型定性，产出评分卡和可落地的修复建议。

姊妹工具：[`hekouwang-claude-md-doctor-skill`](https://github.com/huiyonghkw/hekouwang-claude-md-doctor-skill)（体检 CLAUDE.md）。

## 核心判据

> SKILL.md 是模型"决定要不要加载、加载后照着做"的运行时指令包。
> `description` 决定它何时被唤醒；正文越精简越准；厚重细节要能"按需展开"
> （references/ 用到再读），而不是每次触发就把全部细节灌进上下文。

## 用法

```bash
# 体检一个 skill（目录里要有 SKILL.md）
python3 check.py ~/.claude/skills/my-skill

# 机器可读 JSON（进 CI）
python3 check.py ~/.claude/skills/my-skill --json
```

退出码：有 FAIL → 1，否则 0。零依赖，仅用 Python3 标准库。

## 检查项（12 项加权）

| 权重 | 项 |
|---|---|
| **1.5（核心）** | 无硬编码密钥 · frontmatter 必填合法 · description 含「何时用」 · SKILL.md ≤500 行 · 渐进披露(拆 references/) · 可移植(无硬编码绝对路径) · 别替模型补它已会的 |
| 1.0（标准） | description ≤1024 · 指针无死链 · 脚本外置 scripts/ |
| 0.6（加内容） | allowed-tools 最小化 · 配套文档(README+CHANGELOG) |

分档：A ≥85 · B ≥70 · C ≥50 · D <50。

## 机检 vs 定性

`check.py` 只判机器能确定的部分。**description 触发得准不准、正文是不是"图书馆"、
是不是在替模型补它已会的知识**——这些要人/模型读正文复核（脚本会标出疑点）。
完整定性流程见 `SKILL.md`。

## 免费 / 付费

- **免费**：`check.py` 的文本 / JSON 报告 + 评分，随便用、可进 CI。
- **付费增值**：品牌可视化体检报告卡（精美分享图），找 `@huiyonghkw`。

---

—— 会勇禾口王的AI笔记 · @huiyonghkw
