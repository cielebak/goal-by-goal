---
name: gbg
description: Convert any plan, PRD, or brief into a sequenced goal-by-goal execution document with reviewer-gated commits. Generates a project brief, per-goal scope/tasks/acceptance criteria, an LLM-reviewer prompt (Codex/Gemini/etc.), a progress tracker, and a reviews directory. Each goal is committed only after reviewer PASS. Use when user wants to "convert plan to goals", "goal by goal plan", "codex-gated plan", "review-gated execution", "break plan into reviewable milestones", or invokes /goal-by-goal:gbg.
---

# Goal-by-Goal Plan

Convert an unstructured plan, PRD, or conversation context into a **goal-by-goal execution document** with a strict reviewer gate between goals. Implementation agent (Claude) executes one goal at a time. Reviewer agent (Codex / Gemini / human senior) reviews read-only after each goal. Commit only on PASS.

## When to use

- Multi-week migrations (platform parity, framework upgrades, stack swaps)
- Large refactors with clear surface area
- Greenfield MVPs that decompose into 5–12 reviewable milestones
- Security hardening / compliance work
- Any plan where "did we actually do it correctly?" needs a second pair of eyes between commits

## When NOT to use

- One-shot bugfixes
- Exploratory spikes without success criteria
- Pure design exploration
- Trivial single-file changes

## Process

### 1. Locate the source plan

Ask user where the plan lives. Accept any of:
- A PRD file path
- A GitHub issue URL (`gh issue view <n> --comments`)
- A conversation summary in chat
- A bullet list

If unclear, ask: "Where does the plan live, or should I draft it from this conversation?"

### 2. Gather project parameters

Ask user (one block, not one-by-one):

1. **Project scope name** (kebab-case, used in paths and commit scope). E.g. `android-parity`, `react-to-solid`, `auth-hardening`.
2. **Reviewer**. Codex / Gemini / GPT / human senior / multi-reviewer.
3. **Required checks** — exact bash commands per platform (build, test, lint). E.g. `./gradlew :app:assembleDebug`, `xcodebuild test ...`, `npm test`.
4. **Locked decisions** — things the user does NOT want re-litigated mid-execution (stack choices, scope boundaries, out-of-scope items).
5. **Current state summary** — known issues, gaps, anything pre-existing.
6. **Language** — copy in PL or EN? (Default EN for code/docs, PL for user-facing strings if iOS/Android app.)
7. **Target goal count** — 5–12 typical. Default 8.

If user says "you decide", make the reasonable call from conversation context. Do not block on ambiguity.

### 3. Draft the goal sequence

Decompose scope into N goals (5–12). Each goal must:

- Be **independently shippable** (app still builds, no half-states).
- Have **measurable acceptance criteria** (not "make it nice").
- End with `Reviewer review PASS` as the final acceptance bullet.
- Build on previous goals — no forward references.

**GOAL 0 convention:** baseline/scaffolding only. Create progress tracker, capture current state, run baseline checks, no product code changes. Always include GOAL 0 unless scope is small (< 5 goals).

**Goal ordering principles:**
- Foundation first (shared layer, contracts, types) before UI
- Auth/security before features that depend on user identity
- Backend changes minimized and deferred to where strictly needed
- Visual parity / polish near the end
- Release readiness last

### 4. Quiz the user on the breakdown

Present numbered goal list. For each:
- **Title**
- **One-sentence scope**
- **Top 3 tasks** (truncated)
- **Acceptance criteria headline**

Ask:
- Granularity right? (too coarse / too fine)
- Order correct?
- Any goal should split or merge?
- Anything missing?

Iterate until approved.

### 5. Generate the artifacts

Create these files (use templates in `templates/`):

1. **`<SCOPE>_BRIEF_<YYYY-MM-DD>.md`** in repo root — full brief
2. **`docs/<scope>/agent-progress.md`** — tracker with goal table
3. **`docs/<scope>/reviews/.gitkeep`** — keeps empty dir in git
4. **CLAUDE.md addition** — optional workflow section appended

Replace placeholders in templates with gathered parameters.

### 6. Generate the reviewer prompt

The reviewer prompt is the contract for the review gate. Customize the 10 focus points to the stack:

- iOS/Android/KMP → runtime bugs, Swift/Kotlin compile, REST contract, data compat, Compose/SwiftUI state, platform correctness, security, tests
- Web frontend → runtime bugs, type safety, SSR/CSR, accessibility, perf budget, bundle size, security, tests
- Backend → API contract, schema migrations, query performance, security (authn/authz/injection), error handling, observability, tests
- Infra/DevOps → idempotency, secret handling, rollback path, drift, monitoring, cost

Output format is fixed:
- `FINAL VERDICT: PASS or FAIL`
- `BLOCKERS`
- `SHOULD FIX`
- `NITS`
- `COMMANDS / FILES REVIEWED`
- `EXACT FIX RECOMMENDATIONS`

### 7. Print the execution snippet

Show user how to kick off goal N:

```text
/goal Run GOAL 0 only from <SCOPE>_BRIEF_<DATE>.md. Do not continue to GOAL 1.
```

And the commit format:
```text
feat(<scope>-goal-N): <summary>
fix(<scope>-goal-N): <summary after review fix>
```

## Anti-patterns

- **Don't** generate all goal details upfront if scope is fuzzy. GOAL 0 captures baseline; later goals can be refined as understanding lands.
- **Don't** make goals depend on parallel execution. Sequential by design.
- **Don't** skip GOAL 0 on non-trivial scope. Baseline saves arguments later.
- **Don't** let acceptance criteria be subjective ("looks good", "feels right"). Always concrete.
- **Don't** allow commits without reviewer PASS. The whole point is the gate.
- **Don't** re-litigate locked decisions mid-execution. If user changes scope, update the brief explicitly.

## Templates

- `templates/BRIEF.md` — full project brief skeleton
- `templates/agent-progress.md` — tracker skeleton with goal table
- `templates/reviewer-prompt.md` — reviewer contract (Codex/Gemini/etc.)
- `templates/claude-md-addition.md` — paragraph to append to project CLAUDE.md

## Output checklist

Before declaring skill done, verify:

- [ ] Brief file exists at repo root with absolute date in filename
- [ ] All goals have Scope + Tasks (numbered) + Acceptance criteria
- [ ] Every goal ends with "Reviewer review PASS" as final acceptance bullet
- [ ] Required checks block has actual commands, not placeholders
- [ ] Reviewer prompt is concrete to the stack (not generic)
- [ ] `docs/<scope>/agent-progress.md` table lists every goal with status `pending`
- [ ] `docs/<scope>/reviews/.gitkeep` present so dir survives git
- [ ] Locked decisions section explicit
- [ ] Commit convention stated
- [ ] User shown the `/goal` kickoff command

## Reference implementation

The canonical example is a multi-week mobile platform-parity migration: 9 goals
(0–8), Codex as the read-only reviewer, with a visible "Round 1 FAIL → Round 2
PASS" pattern captured in each `docs/<scope>/reviews/goal-XX-codex.md`. The
review gate caught real cross-platform contract drift before it was committed —
which is the whole point of the pattern.
