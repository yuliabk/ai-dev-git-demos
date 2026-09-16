#!/usr/bin/env bash
# מעלה את התיקייה הזו כ-repo ציבורי ל-GitHub. דורש: gh auth login
set -e
REPO="${1:-ai-dev-git-demos}"
cd "$(dirname "$0")"
[ -d .git ] || git init -q -b main
git add .
git commit -qm "Git demos for AI developers course" || true
gh repo create "$REPO" --public --source=. --push \
  --description "Git demos for AI coding agents: worktrees, protecting main, OpenSpec"
gh repo view --web
