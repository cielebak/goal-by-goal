## {{PROJECT_TITLE}} Workflow

For {{PROJECT_TITLE}} work, use:

- `{{BRIEF_FILENAME}}` as the source of truth.
- {{IMPLEMENTER}} implements.
- {{REVIEWER}} reviews only.
- Execute one goal at a time using `/goal Run GOAL N only from {{BRIEF_FILENAME}}. Do not continue to GOAL N+1.`
- Do not jump ahead.
- Do not re-litigate locked decisions.
- After each goal, update `docs/{{SCOPE}}/agent-progress.md`.
- Run {{REVIEWER}} review and save it to `docs/{{SCOPE}}/reviews/goal-XX-{{REVIEWER_SLUG}}.md`.
- Commit only after {{REVIEWER}} review PASS. Use `feat({{SCOPE}}-goal-N): <summary>` and `fix({{SCOPE}}-goal-N): <summary>` for post-review fixes.
