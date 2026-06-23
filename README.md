# goal-by-goal

![Claude Code — Goal by goal](./assets/screenshot.jpg)

A [Claude Code](https://claude.com/claude-code) plugin. One skill, `gbg`, turns a
plan/PRD/brief into a sequenced **goal-by-goal** execution document where every
commit passes a read-only review gate (Codex by default, Claude, or a human)
before it lands.

## Why

You bring a plan; `gbg` turns it into a sequence of goals and **runs a review
after every single goal**. Nothing gets committed until the reviewer says PASS.

That cadence is the whole point: catching each goal's bugs the moment they appear
— instead of five commits later — means **fewer bugs reach `main` and the work
lands far more solid**. `gbg` forces: **one goal at a time**, **concrete
acceptance criteria**, **a reviewer between commits**, **a paper trail on disk**.

## Flow

```
   plan / PRD / idea
          │
          ▼
   /goal-by-goal:gbg          interview → decompose into 5–12 goals →
          │                   write brief, tracker, reviewer prompt, review script
          ▼
   review the plan      ──►  scripts/gbg-review.sh <scope> plan
          │                  (sound? ordered? gap-free?)  FAIL → fix brief, re-review
          ▼
  ┌─────────────────────  for each goal N  ─────────────────────┐
  │                                                             │
  │   implement scope                                           │
  │        │                                                    │
  │        ▼                                                    │
  │   run required checks  (build · test · lint)                │
  │        │                                                    │
  │        ▼                                                    │
  │   review gate   ──►  scripts/gbg-review.sh <scope> N        │
  │        │                                                    │
  │    ┌───┴────┐                                               │
  │  ❌ FAIL   ✅ PASS                                            │
  │    │         │                                              │
  │    ▼         ▼                                              │
  │  fix       commit  feat(<scope>-goal-N)                     │
  │  blockers    │                                              │
  │    └──re-run─┘                                              │
  │                                                             │
  └──────────────────────────┬──────────────────────────────────┘
                             ▼
                   next goal → … → done
```

## Install

```text
/plugin marketplace add cielebak/goal-by-goal
/plugin install goal-by-goal@goal-by-goal
```

Then reload and run `/goal-by-goal:gbg` (or just describe the intent).

## What it does

The skill interviews you (scope name, reviewer, required checks, locked
decisions, goal count), decomposes the work into 5–12 shippable goals, and
generates:

```
<SCOPE>_BRIEF_<YYYY-MM-DD>.md     # brief: locked decisions, every goal + acceptance criteria
docs/<scope>/agent-progress.md    # tracker, one row per goal
docs/<scope>/reviewer-prompt.md   # the review contract, tuned to your stack
docs/<scope>/reviews/             # one goal-XX-<reviewer>.md verdict per goal
scripts/gbg-review.sh             # runnable gate — only for a CLI reviewer (Codex)
```

**Reviewer choice** is asked up front — **Codex** is the default and
recommended; **Claude** (spawned as a read-only review Agent) or any other
reviewer (typed in) also work. For a CLI reviewer the skill generates
`scripts/gbg-review.sh`, tailored to that tool.

> [!WARNING]
> **Why a generated `scripts/gbg-review.sh` instead of calling the reviewer inline?**
> The `codex exec` process is fragile — on a large diff it buffers output, runs
> slow (~5–10 min), and sometimes dies mid-review. A dedicated script makes the
> run reproducible and **babysittable**: launch it in the background, watch it,
> and re-run a single goal if it crashes — without disturbing the rest of the
> flow. Don't kill it early just because it looks stuck; that's usually it still
> buffering, not a hang.

## Run it

```text
/goal Run all goals from <SCOPE>_BRIEF_<DATE>.md, one at a time, reviewing and committing on PASS before advancing.
```

## Use it for

Features that split into a few shippable steps, MVPs, migrations, large
refactors, hardening passes — anything where "did we do it correctly?" deserves
a second pair of eyes before each commit. **Skip it** for one-shot bugfixes,
spikes, and trivial single-file changes.

## License

MIT © cielebak. See [LICENSE](./LICENSE).
