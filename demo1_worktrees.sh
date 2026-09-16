#!/usr/bin/env bash
# Demo 1 - Git Worktrees: several agents working in parallel on the same repo
set -e
pause(){ [ -n "$DEMO_AUTO" ] || read -rp $'\n[Enter] להמשך...' _; }
say(){ printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }

ROOT="${1:-$HOME/worktree-demo}"
rm -rf "$ROOT" && mkdir -p "$ROOT" && cd "$ROOT"

say "1. יוצרים פרויקט רגיל עם branch main"
git init -q -b main shop && cd shop
git config user.email demo@example.com; git config user.name "Demo"
mkdir -p src
echo 'export const price = (qty) => qty * 10;' > src/cart.js
echo '# Shop demo' > README.md
git add . && git commit -qm "initial project"
git log --oneline
pause

say "2. הבעיה: תיקייה אחת = branch אחד בכל רגע"
echo "אם שני סוכנים עובדים באותה תיקייה, הם חולקים אותם קבצים ואותו branch - השינויים שלהם מתערבבים."
git status --short --branch
pause

say "3. הפתרון: worktree לכל סוכן - תיקייה נפרדת, branch נפרד, אותו repo"
git worktree add -q ../shop-backend -b feature/discount
git worktree add -q ../shop-tests   -b feature/tests
git worktree list
ls -1 ..
pause

say "4. 'סוכן 1' עובד ב-shop-backend"
( cd ../shop-backend
  echo 'export const discount = (total) => total > 100 ? total * 0.9 : total;' > src/discount.js
  git add . && git commit -qm "agent-1: add discount rule" && git log --oneline -1 )

say "   'סוכן 2' עובד במקביל ב-shop-tests"
( cd ../shop-tests && mkdir -p tests
  echo "import { price } from '../src/cart.js'; console.assert(price(3) === 30);" > tests/cart.test.js
  git add . && git commit -qm "agent-2: add cart test" && git log --oneline -1 )
echo
echo "שימו לב: בתיקייה הראשית (main) לא השתנה כלום:"
git status --short --branch; ls src
pause

say "5. מאחדים את העבודה (בעולם אמיתי: דרך Pull Request ובדיקה)"
git merge -q --no-edit feature/discount
git merge -q --no-edit feature/tests
git log --oneline --graph --all
pause

say "6. ניקוי"
git worktree remove ../shop-backend
git worktree remove ../shop-tests
git branch -d feature/discount feature/tests
git worktree list
echo
echo "בשימוש עם סוכנים: פותחים טרמינל בכל תיקיית worktree ומריצים שם claude או codex."
