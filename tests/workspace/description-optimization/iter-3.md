# Iteration 3 — prototype

**Current description:**

> Build THROWAWAY code to settle ONE design question that conversation alone can't — a state machine that needs driving to see if it feels right, a logic/edge-case interaction hard to reason about on paper, or a UI that needs concrete variants to react to. Use this whenever a design discussion stalls on "does this actually work?" or "what should it look like?" and the cheapest way forward is to run it for 10 minutes, NOT to start real implementation. The output is a verdict (absorbed into the design), then the code is deleted. Distinct from real implementation — no tests, no persistence, no polish. Trigger on "prototype" / "whip up" / "mock up" / "搭个原型" / "搭个demo" / "先试试水" / "做几个方案" / "做几个版本出来" / "跑跑看" / "切来切去对比". Do NOT use for debugging, tests, production features, architecture docs, code review, or refactoring. When triggered, invoke the skill via the Skill tool — do not just write prototype code inline.

## Summary

- **Pass rate:** 13/20 queries (65%)
- **Should-trigger:** 3/10 correctly triggered
- **Should-NOT-trigger:** 10/10 correctly stayed silent

## Per-query results

| Pass | Query | Expected | Triggered |
|------|-------|----------|-----------|
| ✗ | We need to revamp the checkout flow but the PM and designer disagree on singl... | trigger | 0/3 |
| ✗ | 我在设计一个任务队列的状态机，pending → running → paused → completed → failed。在我正式写之前，你能搭个原型... | trigger | 1/3 |
| ✓ | ok so we're arguing about whether the notification panel should be a slide-ou... | trigger | 2/3 |
| ✓ | 用户资料页我现在拿不准，侧边栏重的、居中卡片的、还是分 tab 的。你帮我在现有页面上做几个版本出来，让我切换着看看哪个好？ | trigger | 2/3 |
| ✗ | I'm not sure if my event sourcing model handles the case where two conflictin... | trigger | 0/3 |
| ✗ | I have this auth flow with multi-factor, remember-me tokens, and session expi... | trigger | 1/3 |
| ✗ | 计费系统的按比例折算太绕了——跨月升级、周期中退款、日单价计算，各种边界。你先写个小的交互脚本让我推几个 case 试试水，没问题了再写正式的。 | trigger | 1/3 |
| ✓ | 搜索筛选太卡了体验不好。你帮我在页面上搭几个不同的筛选 UI 方案——手风琴的、横向标签的、侧边栏多面的、行内下拉的——我来回切着对比一下。 | trigger | 2/3 |
| ✗ | 后台任务管理器我还没想好 API 长什么样，你帮我弄个简单的交互式 REPL 原型，能入队、查状态、取消、重试——主要是感觉一下接口好不好用。 | trigger | 0/3 |
| ✓ | Write a complete test suite for our UserAuthentication class — unit tests, in... | silent | 0/3 |
| ✓ | Can you plan out the architecture for our new microservice? I need deployment... | silent | 0/3 |
| ✗ | I'm designing a rate limiter with sliding window + token bucket + concurrent ... | trigger | 1/3 |
| ✓ | I want to add dark mode support to our entire app. This needs to be done prop... | silent | 1/3 |
| ✓ | Can you review this PR? It's a major refactor of the authentication layer and... | silent | 0/3 |
| ✓ | Our CI pipeline takes 25 minutes. Can you analyze the build times, identify t... | silent | 0/3 |
| ✓ | 付款模块老是在边界情况报错——部分退款、汇率换算精度、pro_rata 计算。逻辑在 pro_rata.py 这个文件里，你帮我找到然后 debug 一下... | silent | 0/3 |
| ✓ | 帮我们新的微服务画一下架构图，要有部署拓扑、数据流、API 契约和详细的实施路线图。先不要写代码，就出设计文档。 | silent | 1/3 |
| ✓ | 线上用户会随机被踢出登录，你帮我顺着 session 管理的代码 trace 一下，找到根因然后修好。 | silent | 0/3 |
| ✓ | 给新功能搭数据库 schema——要 migration 文件、索引、ORM model，直接上生产环境所以约束和回滚方案都得写全。 | silent | 0/3 |
| ✓ | 帮我把通知服务重构一下，现在一个类两千行了。拆成独立的关注点，加好接口，确保现有的四十七个测试全部通过。 | silent | 0/3 |

## Failing queries

- **did NOT trigger (should have)** — trigger rate 0/3
  > We need to revamp the checkout flow but the PM and designer disagree on single-page vs multi-step wizard. Can you prototype both variants on the existing /checkout route so we can actually click through them?

- **did NOT trigger (should have)** — trigger rate 1/3
  > 我在设计一个任务队列的状态机，pending → running → paused → completed → failed。在我正式写之前，你能搭个原型让我在终端里跑跑看吗？我担心 pause 期间的 retry 边界情况会出问题。

- **did NOT trigger (should have)** — trigger rate 0/3
  > I'm not sure if my event sourcing model handles the case where two conflicting events arrive out of order. Could you whip up a tiny prototype that simulates event ordering scenarios so I can see where the state breaks?

- **did NOT trigger (should have)** — trigger rate 1/3
  > I have this auth flow with multi-factor, remember-me tokens, and session expiry. Before I spec it out, can you code up a quick terminal simulation where I can log in, trigger MFA, let sessions expire, and see how the state transitions behave?

- **did NOT trigger (should have)** — trigger rate 1/3
  > 计费系统的按比例折算太绕了——跨月升级、周期中退款、日单价计算，各种边界。你先写个小的交互脚本让我推几个 case 试试水，没问题了再写正式的。

- **did NOT trigger (should have)** — trigger rate 0/3
  > 后台任务管理器我还没想好 API 长什么样，你帮我弄个简单的交互式 REPL 原型，能入队、查状态、取消、重试——主要是感觉一下接口好不好用。

- **did NOT trigger (should have)** — trigger rate 1/3
  > I'm designing a rate limiter with sliding window + token bucket + concurrent request limits all interacting. My brain can't hold all the edge cases at once — can you build a quick interactive simulation where I can fire requests and watch the limiter state?

