# {{PROJECT_TITLE}} - Project Brief

> Date: {{YYYY-MM-DD}}
> Source of truth for {{IMPLEMENTER}} during execution.
> Implementer executes one goal at a time.
> Reviewer ({{REVIEWER}}) is used only as a read-only reviewer after each goal.

## What We Are Building

{{ONE_PARAGRAPH_DESCRIPTION}}

## Locked Decisions

{{BULLET_LIST_OF_LOCKED_DECISIONS}}

Do not re-litigate locked decisions unless the user explicitly changes them.

## Current State Summary

{{KNOWN_ISSUES_AND_GAPS}}

## Execution Model

{{IMPLEMENTER}} is the implementation agent.

{{IMPLEMENTER}} must:

- read this file before every goal;
- execute only the requested goal;
- keep the project in a runnable/shippable state;
- update progress docs after the goal;
- run relevant checks;
- ask {{REVIEWER}} for read-only review;
- fix {{REVIEWER}} BLOCKERS;
- commit only after {{REVIEWER}} review PASS.

{{REVIEWER}} must not implement. {{REVIEWER}} only reviews.

## Workflow

Use goal-by-goal execution:

```text
/goal Run GOAL 0 only from {{BRIEF_FILENAME}}. Do not continue to GOAL 1.
```

After completion and review:

```text
/goal Run GOAL 1 only from {{BRIEF_FILENAME}}. Do not continue to GOAL 2.
```

Continue one goal at a time.

Each goal must:

- implement only its scope;
- run relevant checks;
- run {{REVIEWER}} review;
- fix {{REVIEWER}} BLOCKERS;
- update `docs/{{SCOPE}}/agent-progress.md`;
- save review to `docs/{{SCOPE}}/reviews/goal-XX-{{REVIEWER_SLUG}}.md`;
- commit only after review PASS.

Commit format:

```text
feat({{SCOPE}}-goal-N): <summary>
```

Use fixes after review as:

```text
fix({{SCOPE}}-goal-N): <summary>
```

## Required Checks

Use the relevant subset per goal.

{{REQUIRED_CHECKS_BLOCKS}}

If a command is blocked by missing credentials, environment, or external service, document the blocker in `docs/{{SCOPE}}/agent-progress.md` and in the review notes.

## {{REVIEWER}} Review Gate

After every goal, run a read-only {{REVIEWER}} review and save it.

Review prompt:

```text
You are {{REVIEWER}} acting as a strict senior {{STACK_DESCRIPTOR}} reviewer.

Review the repository after the completed "{{PROJECT_TITLE}}" goal.

Focus on:
{{FOCUS_POINTS_NUMBERED_LIST}}

Do not modify files. Review only.

Write the review for a human reading it in 30 seconds. Lead with the verdict,
keep each point to one or two lines, attach the fix to the problem, and omit any
empty section. Output exactly this Markdown:

## Review — Goal <N>: <goal title>

**Verdict: ✅ PASS** — <one-line reason>

### 🔴 Blockers
1. **<short title>** — <what breaks> · `path/to/file:line`
   ↳ Fix: <one concrete action>

### 🟡 Should fix
- **<short title>** — <why it matters> · `path/to/file:line`

### ⚪ Nits
- <minor note> · `path/to/file:line`

---
*Checked:* `<commands run>` · <N files>

Rules: verdict is `✅ PASS` or `❌ FAIL` plus one sentence; drop any empty
heading (a clean PASS is just the verdict line + the Checked footer); one issue
per bullet with its fix inline; always cite file:line; no prose paragraphs.

Mark FAIL whenever there is at least one 🔴 Blocker — i.e. anything that would
break the project, regress prior goals, corrupt data, or fail the goal's
acceptance criteria. Otherwise PASS.
```

Save as:

```text
docs/{{SCOPE}}/reviews/goal-XX-{{REVIEWER_SLUG}}.md
```

Do not continue to the next goal until PASS, unless the only remaining blocker is explicitly external/manual and documented.

---

## GOAL 0 - Baseline, Structure, and Execution Docs

Scope: create the execution framework for {{IMPLEMENTER}} and capture the current project baseline. No product implementation yet.

Tasks:

1. Create `docs/{{SCOPE}}/agent-progress.md`.
2. Create `docs/{{SCOPE}}/reviews/` (with `.gitkeep`).
3. {{GOAL_0_CUSTOM_TASKS}}
4. Run current baseline checks and record results.
5. Run {{REVIEWER}} review for GOAL 0.
6. Commit docs only.

Acceptance criteria:

- `docs/{{SCOPE}}/agent-progress.md` exists.
- Current build/test status is documented.
- No app behavior changed.
- {{REVIEWER}} review PASS.

---

## GOAL 1 - {{GOAL_1_TITLE}}

Scope: {{GOAL_1_SCOPE}}

Tasks:

{{GOAL_1_TASKS}}

Acceptance criteria:

{{GOAL_1_ACCEPTANCE}}
- {{REVIEWER}} review PASS.

---

## GOAL 2 - {{GOAL_2_TITLE}}

Scope: {{GOAL_2_SCOPE}}

Tasks:

{{GOAL_2_TASKS}}

Acceptance criteria:

{{GOAL_2_ACCEPTANCE}}
- {{REVIEWER}} review PASS.

---

{{REPEAT_PATTERN_FOR_REMAINING_GOALS}}

---

## Suggested CLAUDE.md Addition

Add this section to `CLAUDE.md` if this work will be long-running:

```md
## {{PROJECT_TITLE}} Workflow

For {{PROJECT_TITLE}} work, use:

- `{{BRIEF_FILENAME}}` as the source of truth.
- {{IMPLEMENTER}} implements.
- {{REVIEWER}} reviews only.
- Execute one goal at a time using `/goal`.
- Do not jump ahead.
- Do not re-litigate locked decisions.
- After each goal, update `docs/{{SCOPE}}/agent-progress.md`.
- Run {{REVIEWER}} review and save it to `docs/{{SCOPE}}/reviews/goal-XX-{{REVIEWER_SLUG}}.md`.
- Commit only after {{REVIEWER}} review PASS.
```
