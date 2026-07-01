# athena-reasonix

<p align="center">
  <a href="./README.md">English</a>
  &nbsp;·&nbsp;
  <strong>简体中文</strong>
  &nbsp;·&nbsp;
  <a href="./docs/UPSTREAM.md">上游项目</a>
</p>

**雅典娜的守卫，移植到 DeepSeek Reasonix。** 同样 9 位星座人格化子代理，同样的痛点驱动哲学，同样的 grill-me 式头脑风暴 —— 运行在 Reasonix 的前缀缓存优先引擎上，而非 Claude Code。

> 这是 [`athena-guard-superpowers`](https://github.com/Joe-zhouman/athena-guard-superpowers) 的 **Reasonix 移植版**。完整思想渊源见 [docs/UPSTREAM.md](docs/UPSTREAM.md)。如果你用 Claude Code，去原版。如果你用 Reasonix，来对地方了。

---

## 为什么要在 Reasonix 上用 Superpowers？

**DeepSeek 模型做你说的事，而不是做你想的事（do what you say, not what you mean）。**

这是 DeepSeek 与 Claude 的根本差异。Claude 模型会"读心"——推断意图、质疑模糊、填补空白。DeepSeek 模型则精确执行字面指令。给一个模糊的任务，它会忠实地造出错误的东西，全速推进，从不暂停说一句"等等，这不对吧"。

Reasonix 的杀手特性是前缀缓存——99% 以上的缓存命中率、token 成本降到冷会话的 1/5。这是跑长会话最省钱的方式。但如果模型一直在便宜地造错误的东西，成本优势就毫无意义。

**Superpowers 是 DeepSeek 需要而 Claude 不需要的护栏层。**

| DeepSeek 的倾向 | Superpowers 的应对 |
|---|---|
| "做你说的事"——字面执行，不质疑 | **brainstorming + discuss-first** —— 写下代码之前强行澄清 |
| 不会主动提出替代方案 | **writing-spec** —— 设计理由必须解释「为什么这么做而不是别的」 |
| 不会发现自己的 scope creep | **scorpio** —— 独立的 spec 合规审查 |
| 忠实执行，跳过质量判断 | **taurus** —— 独立的代码质量审查 |
| 跑得快，坏得也快 | **aries** —— 对抗性运行时测试 |
| 没有内在的怀疑能力 | 每个审查关卡都是独立 agent，不是实现者自查 |

每个 skill 和每个守卫都是在 DeepSeek 的天生盲区里**人为制造的检查点**。目的不是让 DeepSeek 变得像 Claude——而是在 DeepSeek 的优势（速度、成本、服从性）外面加上安全护栏。当指令正确时，服从就是美德；superpowers 确保在服从启动之前，指令本身是正确的。

一句话：**Reasonix 让 DeepSeek 便宜。Superpowers 让 DeepSeek 安全。**

---

## 为什么要有两个仓库？

Claude Code 和 Reasonix 是**两个不同的运行时**——不同的 agent 体系、不同的权限模型、不同的持久化约定。移植不是复制粘贴，而是概念翻译：

| 层面 | athena-superpowers (Claude Code) | athena-reasonix (Reasonix) |
|---|---|---|
| Agent 格式 | YAML frontmatter + `tools`/`disallowedTools`/`maxTurns` | YAML frontmatter + `runAs: subagent`/`allowed-tools` |
| 模型层级 | `fable`/`sonnet`/`haiku`（Claude Code 模型名） | `deepseek-pro`/`deepseek-flash`（在 `reasonix.toml` 中由 provider 定义） |
| Agent 调度 | `Agent(subagent_type="capricorn", ...)` | `run_skill({name: "capricorn", arguments: "..."})` |
| 斜杠命令 | `disable-model-invocation: true` | `.reasonix/commands/` 下的自定义命令 |
| 持久化 | `docs/superpowers/`（athena 约定） | 沿用相同约定；Reasonix 还有 `REASONIX.md`/`AGENTS.md` |
| 安装 | Shell 脚本 + 符号链接 | Clone 到 `~/.reasonix/skills/athena/` |

**同一套哲学，不同的运行时。** 两个仓库共享：9 位星座守卫、痛点驱动开发、文件持久化、独立审查关卡，以及"有个性的 agent 更好用"的信念。

---

## 🪟 平台支持 —— 仅 Windows 桌面端

本仓库只面向 **Reasonix Windows 桌面端**，仅此一端。Linux、macOS、TUI/CLI **不在**支持范围内——这是有意为之，不是疏漏。

**为什么只做 Windows？** 因为在其他平台上你本来就有更好的选择：

| 平台 | 更推荐用 | 原因 |
|---|---|---|
| **Linux** | Claude Code TUI | 终端 DX 是一等公民；Reasonix 的前缀缓存优势在常驻机器上没那么关键 |
| **macOS** | Claude Code 桌面端 | 原生、打磨充分，是参考实现 |
| **Windows** | **athena-reasonix**（本仓库） | Reasonix 桌面端是 DeepSeek 成本优势 + 这套护栏真正一起发挥价值的地方——也是本仓库服务的人群实际在用的端 |

Reasonix 本身是跨平台的，但本仓库**只针对 Windows 桌面端做验证**。在 Linux/macOS 上出的问题是有意接受的已知缺口——只有当它**同时**在 Windows 桌面端也出问题时，才值得提 issue。具体而言：

- **brainstorming 的可视化对比功能**假设 Windows shell 环境，未在 Linux/macOS TUI 下测试。
- 安装说明假设 Windows 下的 `~/.reasonix/skills/athena/` 布局。

如果你在 Linux 或 macOS 上，几乎可以肯定你想要的是 [Claude Code](https://claude.com/claude-code)（或面向 Claude Code 的上游 [`athena-superpowers`](https://github.com/Joe-zhouman/athena-superpowers)），而不是本仓库。

---

## ⚠️ Session-start 注入 —— 本仓库的做法

在 Claude Code 里，superpowers 的 `SessionStart` hook 会把 `using-superpowers` skill 注入到每个会话的上下文。这个注入正是精髓所在：它让模型在行动前先查 skill。

**Reasonix 有 `SessionStart` hook，但它不注入到模型上下文。** 按运行时源码（`internal/hook/runner.go`），SessionStart 的用途是「side effects（日志、准备工作、桌面通知）」——它的 stdout 只显示给用户，不折进系统提示。（对比：`PreCompact` / `PostLLMCall` / `UserPromptSubmit` 这些 hook 的 stdout **会**喂回模型；唯独 SessionStart 故意不这么做。）

所以本仓库**不能**照搬 Claude Code 的 `hooks/session-start` 脚本指望它生效——运行时只会把输出打印出来。取而代之，**本仓库的 session-start 注入靠 repo 根的 `AGENTS.md`**。Reasonix 在 boot 阶段把 `AGENTS.md`（优先级：`REASONIX.md` > `AGENTS.md` > `CLAUDE.md`）折进每个会话的**cache-stable 系统提示前缀**。那份文件承载 skill 优先的纪律；完整论证留在 `using-superpowers` skill 里按需加载。

**代价：** `AGENTS.md` 是静态前缀，不是哈希钉住的 hook 输出，所以没有 Claude Code hook 那个完整性校验护栏。保持该文件简短、改动时审一眼——每个字节都会进每个会话的前缀缓存。

**根治方向：** 上游 Reasonix 可以让 SessionStart 的 stdout 像 `additionalContext` 一样注入（类似 Claude Code）。这是运行时层面的缺口，本仓库单独无法解决。

---

## 架构

### 9 位守卫子代理

每位守卫是一个 Reasonix **subagent skill**（`runAs: subagent`）。它们在隔离的子循环中运行——工具调用和推理过程不会污染父上下文，只有最终结论返回。

| 守卫 | 星座 | 角色 | 模型层级 | 自动触发？ |
|------|------|------|---------|----------|
| **capricorn** | 摩羯 | 执行者——TDD，一次一个任务 | deepseek-pro | 每个任务 |
| **scorpio** | 天蝎 | Spec 合规审查者 | deepseek-pro | 每批次一次 |
| **taurus** | 金牛 | 代码质量审查者 | deepseek-pro | scorpio 之后 |
| **libra** | 天秤 | 计划/Spec 把关人 | deepseek-pro | 实现之前 |
| **cancer** | 巨蟹 | Bug 修复者（复现→根因→修复） | deepseek-pro | 收到 bug 报告时 |
| **aries** | 白羊 | 对抗性测试者——运行时攻击 | deepseek-pro | Aries Gate 触发时 |
| **virgo** | 处女 | 本地代码库探索者（只读） | deepseek-flash | 按需 |
| **sagittarius** | 射手 | 外部研究员（网络、文档、论文） | deepseek-flash | 按需 |
| **pisces** | 双鱼 | 文本润色——去 AI 味 + agent 可读性 | deepseek-pro | 按需 |

**Reasonix 中的模型层级：**
- `deepseek-pro`（≈ Claude Code 的 sonnet/fable 层级）：capricorn、scorpio、taurus、libra、cancer、aries、pisces
- `deepseek-flash`（≈ Claude Code 的 haiku 层级）：virgo、sagittarius

这些是默认值。可通过 frontmatter 中的 `model:` 逐 skill 覆盖，或在 `reasonix.toml` 中用 `subagent_models` 全局覆盖。

### Skills（内联）

没有 `runAs: subagent` 的 Reasonix skill 会折叠到父上下文中（内联）。这些是操作手册：

| Skill | 用途 |
|-------|------|
| **brainstorming** | Grill-me 访谈 → 设计决策 |
| **writing-spec** | 痛点驱动的 spec 格式 |
| **subagent-driven-development** | 每个任务派 capricorn + 批次结束后派 scorpio/taurus |
| **dispatching-parallel-agents** | 将独立工作扇出到子代理 |
| **systematic-debugging** | 可复现 bug → 根因分析 |
| **using-superpowers** | Skill 调用规范 |
| **verification-before-completion** | 完成前检查清单 |
| **executing-plans** | 计划 → 任务拆解 → 执行 |
| **writing-plans** | 计划文档结构 |
| **finishing-a-development-branch** | PR 就绪检查清单 |
| **requesting-code-review** | 代码审查请求格式 |
| **receiving-code-review** | 代码审查响应格式 |
| **test-driven-development** | TDD 规范 |
| **using-git-worktrees** | Git worktree 工作流 |

### 补充 Skills（来自 Matt Pocock）

| Skill | 用途 |
|-------|------|
| **diagnosing-bugs** | 无清晰复现路径的疑难 bug |
| **to-prd** | 对话 → PRD 合成 |
| **prototype** | 为回答设计问题而构建的一次性原型 |

### 斜杠命令

仅供用户手动调用的自定义命令（模型不会自动触发）：

| 命令 | 用途 |
|------|------|
| `/grill-me` | 不留情面地盘问你的计划/设计 |
| `/discuss-first` | 先聊清楚再写代码 |
| `/handoff` | 为下一个会话写交接文档 |

**为什么是命令而不是 skill？** 在 Claude Code 中，这三个有 `disable-model-invocation: true`——它们只能由*用户*手动调用（如 `/grill-me`），模型永远不能自动触发。Reasonix 没有等价的前置元数据字段，但自定义命令天然实现了相同的约束：模型无法自动触发 `/command`，只有用户能。正文是同一个 prompt；包装层决定了"仅用户调用"。*（同上游 athena-guard-superpowers）*

---

## 安装

### 前提条件

- **Windows 桌面端** —— 在 Windows 上已安装 [Reasonix 桌面端](https://github.com/esengine/DeepSeek-Reasonix)。（Linux/macOS/TUI 不支持，见上方[平台支持](#-平台支持--仅-windows-桌面端)。）
- DeepSeek API key（`DEEPSEEK_API_KEY`）
- 已完成 `reasonix setup`
- **仅 brainstorming 可视化对比功能需要：** Node.js + 一个 bash shell（Windows 推荐 Git Bash）。该服务只用 Node 内置模块，无需 `npm install`。如果你不用 brainstorming 的可视化模式，这两样都不需要。

### 安装 athena-reasonix

**推荐 —— 一键安装脚本**（clone + 注入纪律 + 自检）：

```powershell
# Windows（PowerShell 5.1+）
powershell -ExecutionPolicy Bypass -File install.ps1
```

```bash
# Linux / macOS
bash install.sh
```

安装脚本会 clone 到 `~/.reasonix/skills/athena/`，并把 skill 优先的纪律**注入** `~/.reasonix/AGENTS.md`（Reasonix 的全局 session-start memory）。**绝不覆盖**你的 AGENTS.md —— 它靠标记块幂等合并/替换，其余内容一字不动。参数（`-Update`、`-NoCheck`、`-SkipServer`）和跨工具注意事项见 [`install/README.md`](install/README.md)。

**手动安装**（如果你更想自己控制）：

```sh
git clone https://github.com/Joe-zhouman/athena-reasonix.git ~/.reasonix/skills/athena
# 然后自行把仓库的 AGENTS.md 内容合并进 ~/.reasonix/AGENTS.md
# （或只为注入这一步跑一次 install.ps1）。
```

Reasonix 自动发现 `.reasonix/skills/` 下的 skills —— 目录式（`<name>/SKILL.md`）始终被识别。

### 验证

```sh
reasonix          # 启动交互会话
/skills            # 列出已加载的 skills——你应该能看到全部 9 位守卫 + skills
/grill-me          # 测试斜杠命令
```

---

## ⚠️ 射手路由表是个性化配置

Sagittarius 的路由表和工具参考是为 **Joe 的 MCP 配置**（searxng、context7、z-reader 等）构建的。你的 Reasonix 插件不一样。

**第一次派 sagittarius 时，它会：**
1. 读取当前的路由表和工具参考
2. 告诉你："这是为 Joe 的 MCP 配置构建的。你的工具不一样，让我展示我推荐的方案。"
3. 逐行带你走一遍——每行需要什么能力、你实际有哪些工具、提议的替代方案
4. 让你否决或调整每一行
5. 只有在你同意后才重写路由表和参考

不要盲目接受——逐行审查。你的工具，你的路由表。

---

## 与 athena-superpowers 的关系

```
athena-superpowers (Claude Code)          athena-reasonix (Reasonix)
├── .claude-plugin/plugin.json            ├── skills/  (Reasonix 自动发现)
├── user-agents/  (Claude Code agents)    │   ├── capricorn/SKILL.md  (subagent skill)
│   ├── capricorn.md                      │   ├── scorpio/SKILL.md
│   └── ...                               │   └── ...
├── skills/  (Claude Code skills)         ├── commands/  (Reasonix 自定义命令)
│   ├── brainstorming/SKILL.md            │   ├── grill-me.md
│   └── ...                               │   └── ...
├── hooks/  (Claude Code hooks)           ├── refs/  (与 skills 共享)
└── install.sh                            └── README.md
```

Skill 正文几乎一致——主要改动是 frontmatter 和工具名称的移植。Agent 的人格、PHASE 流程和沟通规则完全保留。

---

## For Agents

当 agent 或子代理阅读此仓库时，需要知道以下内容：

### 关键规则

1. **这是 Reasonix，不是 Claude Code。** 子代理通过 `run_skill({name, arguments})` 调用，而非 `Agent(subagent_type=...)`。
2. **工具使用 Reasonix 命名。** `read_file` 而非 `Read`；`write_file` 而非 `Write`；`edit_file` 而非 `Edit`；`grep`/`glob`/`bash`/`ls`/`web_fetch`。
3. **子代理中没有 `Agent` 工具。** 守卫不能调用其他守卫。由主 agent 调度。
4. **没有 `TaskCreate`/`TaskUpdate`/`TaskList`/`TaskGet`。** Reasonix 用 `todo_write` 和 `complete_step` 代替。
5. **模型层级由 provider 定义。** `deepseek-pro` 和 `deepseek-flash` 在 `reasonix.toml` 中配置。用户可能重命名。
6. **射手路由表是个性化配置。** 工具参考描述的是 MCP 工具，可能在用户的设置中不存在。带用户走一遍重建流程——不要静默覆盖。
7. **findings-local.md / findings-external.md** 持久化到 `docs/superpowers/`（与 athena-superpowers 相同约定）。
8. **斜杠命令**如 `/grill-me` 是 `.reasonix/commands/` 下的自定义命令，不是 skills。

### Agent 调度参考

```
主 agent 通过 run_skill 派子代理：

run_skill({name: "capricorn",    arguments: "<任务描述>"})   → 实现
run_skill({name: "scorpio",      arguments: "<spec + git 范围>"})   → 审查 spec 合规性
run_skill({name: "taurus",       arguments: "<git 范围>"})          → 审查代码质量
run_skill({name: "libra",        arguments: "<计划/spec 路径>"})     → 把关计划
run_skill({name: "cancer",       arguments: "<bug 复现>"})          → 修复 bug
run_skill({name: "aries",        arguments: "<目标 + 攻击面>"})  → 运行时攻击
run_skill({name: "virgo",        arguments: "<探索问题>"})→ 绘制代码库地图
run_skill({name: "sagittarius",  arguments: "<研究问题>"})  → 知识狩猎
run_skill({name: "pisces",       arguments: "<待润色文本>"})     → 润色文本
```

### 反模式

- 不要 clone 整个仓库作为项目文件——Reasonix 从约定目录自动发现 skills。
- 不要把 API key 放进配置文件——Reasonix 使用 `api_key_env`。
- 不要引用 `~/.claude/` 路径——这是 Reasonix，用 `~/.reasonix/`。
- 不要用 `Agent()` 调度——Reasonix 用 `run_skill()`。

---

## 反馈与 Issue

发现 bug？有功能想法？哪里不对劲？**向本仓库提 issue。**

如果你不知道怎么在 GitHub 或 GitCode 上提 issue——**让你的 agent 教你。** 这就是 agent 该干的事。直接输入类似「教我如何为 X 提一个 issue」的话，它会带你走完流程。

---

## License

MIT — 参见 [LICENSE](https://github.com/esengine/DeepSeek-Reasonix/blob/master/LICENSE)（继承自上游 athena-superpowers）。
