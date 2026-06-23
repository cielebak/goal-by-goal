#!/usr/bin/env bash
# Reviewer wrapper for the goal-by-goal review gate.
#
# Runs the read-only reviewer against the current diff for one goal, using the
# scope's reviewer prompt, and saves the verdict under that scope's reviews dir.
# The reviewer only reviews — it never modifies files. Commit only on PASS.
#
# Layout it expects (created by the gbg skill):
#   docs/<scope>/reviewer-prompt.md     # the review contract
#   docs/<scope>/reviews/               # where goal-XX-<reviewer>.md verdicts land
#
# Usage:
#   scripts/codex-review.sh <scope> <goal-number> [git-range]
#
#   <scope>        kebab-case scope name, e.g. paywall, android-parity
#                  (must have docs/<scope>/reviewer-prompt.md)
#   <goal-number>  integer; zero-padded to 2 digits in the output filename
#   [git-range]    what to diff (default: HEAD = uncommitted working tree)
#                  e.g. "main...HEAD", "HEAD~1", a commit sha
#
# Examples:
#   scripts/codex-review.sh paywall 7              # review working tree for goal 7
#   scripts/codex-review.sh android-parity 3 HEAD~1
#
# Env overrides:
#   REVIEWER          filename suffix for the verdict (default: codex)
#   CODEX_MODEL       reviewer model (default: gpt-5.3-codex)
#   CODEX_REASONING   reasoning effort: low|medium|high (default: high)
#
# Output is teed to docs/<scope>/reviews/goal-XX-<reviewer>.md.
# Slow on big diffs (~5-10 min) — prefer backgrounding:
#   scripts/codex-review.sh paywall 7 &

set -euo pipefail

REVIEWER="${REVIEWER:-codex}"
MODEL="${CODEX_MODEL:-gpt-5.3-codex}"
EFFORT="${CODEX_REASONING:-high}"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

usage() {
  sed -n '2,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
  exit "${1:-1}"
}

scope="${1:-}"
goal="${2:-}"
range="${3:-HEAD}"

[[ "${scope}" == "-h" || "${scope}" == "--help" ]] && usage 0
[[ -z "${scope}" || -z "${goal}" ]] && usage 1

prompt_file="${REPO_ROOT}/docs/${scope}/reviewer-prompt.md"
reviews_dir="${REPO_ROOT}/docs/${scope}/reviews"

if [[ ! -f "${prompt_file}" ]]; then
  echo "no reviewer prompt at ${prompt_file}" >&2
  echo "scopes that have one:" >&2
  ls -d "${REPO_ROOT}"/docs/*/reviewer-prompt.md 2>/dev/null \
    | sed 's#.*/docs/##;s#/reviewer-prompt.md##' >&2 || true
  exit 1
fi

if ! [[ "${goal}" =~ ^[0-9]+$ ]]; then
  echo "goal-number must be an integer, got: ${goal}" >&2
  exit 1
fi
printf -v goal_padded '%02d' "${goal}"

mkdir -p "${reviews_dir}"
out_file="${reviews_dir}/goal-${goal_padded}-${REVIEWER}.md"

tmp=$(mktemp)
trap 'rm -f "${tmp}"' EXIT
{
  cat "${prompt_file}"
  printf '\n\n---\n\n## Goal under review: %s\n\n' "${goal}"
  printf '### Diff (`git diff %s`)\n\n```diff\n' "${range}"
  git -C "${REPO_ROOT}" diff "${range}"
  printf '\n```\n'
} >"${tmp}"

echo "Reviewing ${scope} goal ${goal} (range: ${range}) -> ${out_file}" >&2

# Reviewer reads the prompt + diff from stdin. Read-only: never writes files.
# stdin is the prompt file (closed at EOF) — no interactive hang.
codex exec \
  -c model_reasoning_effort="${EFFORT}" \
  -m "${MODEL}" \
  --sandbox read-only \
  --cd "${REPO_ROOT}" \
  - <"${tmp}" | tee "${out_file}"

echo "Saved verdict to ${out_file}" >&2
