#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=1
TITLE="chore: update automation docs"
BODY="Automated update from Klarpakke scripts."
BASE="main"
ALLOW_DIRTY=0
BRANCH_PREFIX="auto/klarpakke"

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/02-git-pr.sh --apply [--title "t"] [--body "b"] [--base main] [--allow-dirty]

Behavior:
  - Creates a new branch (timestamped)
  - git add -A, commit, push
  - Opens PR using gh if available; otherwise prints compare URL
Defaults:
  - --dry-run (no changes)
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) DRY_RUN=0; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    --title) TITLE="${2:-}"; shift 2 ;;
    --body) BODY="${2:-}"; shift 2 ;;
    --base) BASE="${2:-main}"; shift 2 ;;
    --allow-dirty) ALLOW_DIRTY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown arg: $1" >&2; usage; exit 2 ;;
  esac
done

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "ERROR: Not inside a git repo." >&2
  exit 1
fi

if [[ "$ALLOW_DIRTY" -eq 0 ]]; then
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "ERROR: Working tree not clean. Commit/stash first or use --allow-dirty." >&2
    exit 1
  fi
fi

ts_utc="$(date -u +'%Y%m%d-%H%M%S')"  # macOS+Linux compatible
branch="${BRANCH_PREFIX}-${ts_utc}"

remote_url="$(git remote get-url origin 2>/dev/null || true)"
if [[ -z "$remote_url" ]]; then
  echo "ERROR: Missing git remote 'origin'." >&2
  exit 1
fi

# best-effort repo slug parse (supports https and ssh)
repo_slug=""
if [[ "$remote_url" =~ github\.com[:/](.+)\.git$ ]]; then
  repo_slug="${BASH_REMATCH[1]}"
elif [[ "$remote_url" =~ github\.com[:/](.+)$ ]]; then
  repo_slug="${BASH_REMATCH[1]}"
fi

log_dir="logs"
mkdir -p "$log_dir"
log_file="${log_dir}/git-pr-${ts_utc}.log"

{
  echo "TITLE=$TITLE"
  echo "BASE=$BASE"
  echo "BRANCH=$branch"
  echo "REMOTE=$remote_url"
  echo "REPO_SLUG=$repo_slug"
} > "$log_file"

if [[ "$DRY_RUN" -eq 1 ]]; then
  echo "DRY-RUN: would create branch $branch, commit, push, open PR"
  echo "LOG: $log_file"
  exit 0
fi

git fetch origin "$BASE" >/dev/null 2>&1 || true
git checkout -b "$branch"

git add -A
if git diff --cached --quiet; then
  echo "Nothing to commit. Exiting."
  exit 0
fi

git commit -m "$TITLE" -m "$BODY"
git push -u origin "$branch"

if command -v gh >/dev/null 2>&1; then
  # gh must be authenticated (gh auth login) OR GITHUB_TOKEN set for CI contexts
  gh pr create --title "$TITLE" --body "$BODY" --base "$BASE" --head "$branch" || {
    echo "WARN: gh pr create failed; printing compare URL instead." >&2
  }
fi

if [[ -n "$repo_slug" ]]; then
  echo "PR URL (manual): https://github.com/${repo_slug}/compare/${BASE}...${branch}?expand=1"
else
  echo "PR URL: (could not infer repo slug from origin)"
fi

echo "DONE. LOG: $log_file"
