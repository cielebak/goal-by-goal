# goal-by-goal

> Turn any plan, PRD, or messy brief into a **sequenced, reviewer-gated execution document** — and let Claude run it one goal at a time, committing only after a second pair of eyes says PASS.

A [Claude Code](https://claude.com/claude-code) plugin. It ships a single skill, `goal-by-goal`, that converts a fuzzy plan into a disciplined milestone sequence where **every commit passes through an independent review gate** (Codex, Gemini, or a human senior) before it lands.

---

## Why

Large work — migrations, refactors, MVPs, hardening — fails in the same way: the agent races ahead, half-finishes three things at once, and you discover the breakage five commits later. `goal-by-goal` forces a different shape:

- **One goal at a time.** Each goal is independently shippable. The repo always builds.
- **Concrete acceptance criteria.** No "make it nice" — every goal states how you'll *know* it's done.
- **A review gate between commits.** A read-only reviewer (Codex/Gemini/human) checks each goal against its acceptance criteria. `FAIL` blocks the commit; `PASS` unblocks it.
- **A paper trail.** Brief, progress tracker, and one saved review per goal — so "did we actually do it correctly?" has an answer on disk.

The pattern is proven on a multi-week mobile platform-parity migration (9 goals, Codex reviewer, visible "Round 1 FAIL → Round 2 PASS" history).

---

## Install

In Claude Code:

```text
/plugin marketplace add cielebak/goal-by-goal
/plugin install goal-by-goal@goal-by-goal
```

Then restart or reload, and the skill is available. Invoke it with:

```text
/goal-by-goal
```

…or just describe the intent ("break this PRD into reviewable milestones", "convert plan to goals", "codex-gated execution") and Claude will reach for it.

> **Uninstall / update:** `/plugin uninstall goal-by-goal@goal-by-goal`, or `/plugin marketplace update goal-by-goal` to pull the latest.

---

## How it works

When you run the skill, it walks through seven steps:

1. **Locate the source plan** — a file path, a GitHub issue, or this conversation.
2. **Gather parameters** — scope name, reviewer, required check commands, locked decisions, current state, language, target goal count.
3. **Draft the goal sequence** — 5–12 goals, foundation-first, each shippable.
4. **Quiz you on the breakdown** — granularity, ordering, splits/merges — iterate until approved.
5. **Generate the artifacts** (see below).
6. **Generate the reviewer prompt** — a fixed-format contract tuned to your stack.
7. **Print the kickoff snippet** — how to run GOAL 0, and the commit convention.

### What it generates

```
<SCOPE>_BRIEF_<YYYY-MM-DD>.md      # full brief: locked decisions, workflow, every goal
docs/<scope>/agent-progress.md      # tracker table, one row per goal, status column
docs/<scope>/reviews/.gitkeep       # where each goal-XX-<reviewer>.md verdict lands
# (optional) a CLAUDE.md workflow section
```

### The review gate

Each goal ends with a single non-negotiable acceptance bullet: **`Reviewer review PASS`**. The reviewer runs read-only and returns a fixed format:

```text
FINAL VERDICT: PASS or FAIL
BLOCKERS
SHOULD FIX
NITS
COMMANDS / FILES REVIEWED
EXACT FIX RECOMMENDATIONS
```

Commit format is enforced too:

```text
feat(<scope>-goal-N): <summary>
fix(<scope>-goal-N): <summary after a review fix>
```

---

## Pairs well with `/goal` and auto mode

`goal-by-goal` *authors* the plan; you *execute* it one goal at a time.

### With `/goal`

If you have a goal-runner command (e.g. `/goal`), the kickoff looks like:

```text
/goal Run GOAL 0 only from <SCOPE>_BRIEF_<DATE>.md. Do not continue to GOAL 1.
```

`/goal` sets a session goal and keeps Claude working toward it — it won't stop
until the goal's condition holds. Because each goal in the brief carries
concrete acceptance criteria *and* ends in `Reviewer review PASS`, the goal
runner has an unambiguous, verifiable stop condition for every milestone.
After the reviewer returns PASS and you commit, advance to the next goal.

### With Claude Code auto mode

The brief is built to be run hands-off in **Claude Code auto mode** (execute
without per-step approval). The review gate is exactly what makes that safe:
auto mode supplies the speed, the reviewer (Codex / Gemini / human) supplies
the brakes. Claude implements a goal, runs the required checks, requests the
read-only review, fixes any `BLOCKERS`, and **only commits on `PASS`** — so an
autonomous run still can't land unreviewed code. Locked decisions in the brief
keep auto mode from re-litigating settled scope mid-run.

Sequential by design — no parallel goals, no forward references.

---

## When to use it

**Good fit**
- Multi-week migrations (platform parity, framework upgrades, stack swaps)
- Large refactors with clear surface area
- Greenfield MVPs that decompose into 5–12 milestones
- Security hardening / compliance work

**Skip it for**
- One-shot bugfixes
- Exploratory spikes without success criteria
- Trivial single-file changes

---

## Repository layout

```
.claude-plugin/
  marketplace.json        # marketplace catalog (one plugin)
  plugin.json             # plugin manifest
skills/
  goal-by-goal/
    SKILL.md              # the skill
    templates/            # brief, tracker, reviewer-prompt, CLAUDE.md addition
README.md
LICENSE
```

---

## License

MIT © cielebak. See [LICENSE](./LICENSE).
