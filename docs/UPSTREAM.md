# 上游项目

athena-reasonix 是 [athena-guard-superpowers](https://github.com/Joe-zhouman/athena-guard-superpowers) 的 Reasonix 移植版。

## 思想渊源

```
superpowers (obra)                   ← 上游方法体系
    └── athena-guard-superpowers     ← Joe-zhouman 个人分支（Claude Code）
            └── athena-reasonix      ← DeepSeek Reasonix 移植（本仓库）
```

### superpowers

[obra/superpowers](https://github.com/obra/superpowers) (~5.0.x 时期) 提出了核心理念：

- **Skill 驱动开发**：将工作流编码为可重用的 `SKILL.md` 文件，每个 skill 是一个独立的小型操作手册
- **子代理开发流程**：用 `general-purpose` 子代理执行独立任务，主 agent 负责编排
- **文件持久化**：findings、plans、specs、reviews 写入文件系统，会话间状态可恢复
- **审查关卡**：实现→审查→验收，每个关卡独立验证

### athena-guard-superpowers

Joe-zhouman 的个人分支在此基础上进行了以下改造：

- **12 星座人格化子代理**（9 位已实现）：用圣斗士星矢的人设给每个子代理注入独特个性，来自 [Oh-My-OpenCode](https://github.com/1ncha0s/Oh-My-OpenCode) 的启发
- **痛点驱动开发**：没有痛点 → 不写 spec → 不写代码。设计决策必须解释"为什么这个设计而不是别的"，来自 [Matt Pocock](https://github.com/mattpocock) 的 skill 系列
- **审查流程优化**：审查从"每任务一次"改为"每批次一次"，约 40% 的调度节省，且跨任务问题在聚合审查中可见
- **射手路由表**：sagittarius 根据问题类型自动选择搜索策略（库文档 / 源码 / 学术 / 事实核查）

### athena-reasonix

本仓库将 athena-guard-superpowers 的核心理念移植到 Reasonix 运行时：

- **9 位守卫的完整人格**（正文基本未动）
- **痛点驱动的 spec 写法**
- **grill-me 式头脑风暴**
- **文件持久化约定**（沿用 `docs/superpowers/` 路径）
- **独立审查关卡**（libra → scorpio → taurus → aries）

## 关键差异

| 维度 | athena-superpowers | athena-reasonix |
|------|-------------------|-----------------|
| 运行时 | Claude Code | DeepSeek Reasonix |
| 安装方式 | Claude Code plugin + 符号链接 | Clone 到 `~/.reasonix/skills/athena/` |
| 子代理格式 | `user-agents/*.md` (Claude Code agent) | `skills/*/SKILL.md` (Reasonix subagent skill) |
| 子代理调度 | `Agent(subagent_type="name", ...)` | `run_skill({name: "name", arguments: "..."})` |
| 权限模型 | `.claude/settings.json` hooks | `reasonix.toml` permissions + sandbox |
| 成本优势 | 多模型混用 (GLM + DeepSeek) | DeepSeek 前缀缓存 (99%+ 缓存命中率) |
| 跨平台 | macOS/Linux/Windows (Node.js) | Reasonix 运行时本身跨平台 (Go 单二进制)，但**本仓库只验证/支持 Windows 桌面端**（见 README「平台支持」段） |

## 致谢

- [obra/superpowers](https://github.com/obra/superpowers) — 原始方法体系
- [1ncha0s/Oh-My-OpenCode](https://github.com/1ncha0s/Oh-My-OpenCode) — 人格化子代理的灵感
- [Matt Pocock](https://github.com/mattpocock) — 补充 skill 系列 (diagnosing-bugs, handoff, to-prd, prototype)
- [esengine/DeepSeek-Reasonix](https://github.com/esengine/DeepSeek-Reasonix) — 本仓库运行的平台

## License

MIT，继承自上游 athena-guard-superpowers。
