# Iteration 1 — prototype

**Current description:**

> Build THROWAWAY code to settle ONE design question that conversation alone can't — a state machine that needs driving to see if it feels right, a logic/edge-case interaction hard to reason about on paper, or a UI that needs concrete variants to react to. Use this whenever a design discussion stalls on "does this actually work?" or "what should it look like?" and the cheapest way forward is to run it for 10 minutes, NOT to start real implementation. The output is a verdict (absorbed into the design), then the code is deleted. Distinct from real implementation — no tests, no persistence, no polish.

## Summary

- **Pass rate:** 12/20 queries (60%)
- **Should-trigger:** 3/10 correctly triggered
- **Should-NOT-trigger:** 9/10 correctly stayed silent

## Per-query results

| Pass | Query | Expected | Triggered |
|------|-------|----------|-----------|
| ✓ | I'm not sure if my event sourcing model handles the case where two conflictin... | trigger | 2/3 |
| ✓ | ok so we're arguing about whether the notification panel should be a slide-ou... | trigger | 2/3 |
| ✗ | The billing logic for pro-rating subscriptions is getting complicated — parti... | trigger | 0/3 |
| ✗ | We need to revamp the checkout flow but the PM and designer disagree on singl... | trigger | 0/3 |
| ✓ | I have this auth flow with multi-factor, remember-me tokens, and session expi... | trigger | 2/3 |
| ✗ | I need to decide between three different layouts for our user profile page — ... | trigger | 0/3 |
| ✗ | I want to feel out what the API for our background job manager should look li... | trigger | 1/3 |
| ✗ | The search filters on our product listing feel clunky. Can you mock up 3-4 di... | trigger | 1/3 |
| ✓ | The payment processing module keeps failing on edge cases — partial refunds, ... | silent | 0/3 |
| ✗ | I'm designing a task queue with states pending → running → paused → completed... | trigger | 0/3 |
| ✓ | Write a complete test suite for our UserAuthentication class — unit tests, in... | silent | 0/3 |
| ✗ | There's a bug in production where users get randomly logged out. I need you t... | silent | 2/3 |
| ✓ | Can you plan out the architecture for our new microservice? I need deployment... | silent | 0/3 |
| ✓ | Set up the database schema for our new feature — I need migration files, inde... | silent | 0/3 |
| ✓ | Refactor the notification service — it's become a god class with 2000 lines. ... | silent | 0/3 |
| ✓ | I want to add dark mode support to our entire app. This needs to be done prop... | silent | 0/3 |
| ✓ | Can you review this PR? It's a major refactor of the authentication layer and... | silent | 0/3 |
| ✓ | I need to write a technical spec for the new recommendation engine. This goes... | silent | 0/3 |
| ✓ | Our CI pipeline takes 25 minutes. Can you analyze the build times, identify t... | silent | 0/3 |
| ✗ | I'm designing a rate limiter with sliding window + token bucket + concurrent ... | trigger | 1/3 |

## Failing queries

- **did NOT trigger (should have)** — trigger rate 0/3
  > The billing logic for pro-rating subscriptions is getting complicated — partial months, upgrades mid-cycle, refund calculations. Before writing the real thing, can we prototype the core calculation in a little interactive script so I can test edge cases?

- **did NOT trigger (should have)** — trigger rate 0/3
  > We need to revamp the checkout flow but the PM and designer disagree on single-page vs multi-step wizard. Can you prototype both variants on the existing /checkout route so we can actually click through them?

- **did NOT trigger (should have)** — trigger rate 0/3
  > I need to decide between three different layouts for our user profile page — a sidebar-heavy one, a centered card layout, and a tabbed view. Can you mock up all three so I can flip between them and pick one?

- **did NOT trigger (should have)** — trigger rate 1/3
  > I want to feel out what the API for our background job manager should look like before writing it. Can you build a little interactive REPL where I can enqueue jobs, check status, cancel, retry — just to get a feel for the ergonomics?

- **did NOT trigger (should have)** — trigger rate 1/3
  > The search filters on our product listing feel clunky. Can you mock up 3-4 different filter UI patterns (accordion, horizontal chips, sidebar facets, inline dropdowns) so I can click through them and compare?

- **did NOT trigger (should have)** — trigger rate 0/3
  > I'm designing a task queue with states pending → running → paused → completed → failed. Before I commit to this state machine, can you build a quick terminal app where I can push it through transitions and see if it feels right? I'm worried about the pause-during-retry edge case.

- **triggered (should NOT have)** — trigger rate 2/3
  > There's a bug in production where users get randomly logged out. I need you to trace through the session management code and find the root cause, then fix it properly.

- **did NOT trigger (should have)** — trigger rate 1/3
  > I'm designing a rate limiter with sliding window + token bucket + concurrent request limits all interacting. My brain can't hold all the edge cases at once — can you build a quick interactive simulation where I can fire requests and watch the limiter state?

