#!/usr/bin/env bash
# Demo 2 - Protecting main: branch -> tests -> PR -> CI gate
# Part A runs fully local (git hooks). Part B (optional) runs on GitHub with gh CLI.
set -e
pause(){ [ -n "$DEMO_AUTO" ] || read -rp $'\n[Enter] להמשך...' _; }
say(){ printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }

ROOT="${1:-$HOME/protect-main-demo}"
rm -rf "$ROOT" && mkdir -p "$ROOT" && cd "$ROOT"
git init -q -b main && git config user.email demo@example.com && git config user.name Demo

say "הכנה: פרויקט Node קטן עם טסטים ו-CI"
mkdir -p src test .github/workflows .githooks
cat > package.json <<'J'
{ "name": "protect-main-demo", "type": "module", "scripts": { "test": "node --test" } }
J
cat > src/discount.js <<'J'
export function discount(total) {
  return total > 100 ? total * 0.9 : total;
}
J
cat > test/discount.test.js <<'J'
import test from 'node:test';
import assert from 'node:assert/strict';
import { discount } from '../src/discount.js';
test('10% off above 100', () => assert.equal(discount(200), 180));
test('no discount at 100 or below', () => assert.equal(discount(100), 100));
J
cat > .github/workflows/ci.yml <<'Y'
name: CI
on:
  pull_request:
  push:
    branches: [main]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 22 }
      - run: npm test
Y
# Local guardrail 1: never commit directly on main
cat > .githooks/pre-commit <<'H'
#!/usr/bin/env bash
branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" = "main" ] && [ -z "$ALLOW_MAIN" ]; then
  echo "BLOCKED: אסור לעבוד ישירות על main. פתחו branch: git checkout -b feature/..."
  exit 1
fi
H
# Local guardrail 2: never push with failing tests
cat > .githooks/pre-push <<'H'
#!/usr/bin/env bash
echo "מריץ טסטים לפני push..."
npm test --silent || { echo "BLOCKED: הטסטים נכשלו - אין push."; exit 1; }
H
chmod +x .githooks/*
ALLOW_MAIN=1 git add . && ALLOW_MAIN=1 git commit -qm "initial project with tests and CI"
git config core.hooksPath .githooks
npm test --silent 2>&1 | grep -E "^# (pass|fail)"
pause

say "חוק 1: 'סוכן' מנסה לעשות commit ישירות על main"
echo "// quick fix" >> src/discount.js
git add . ; git commit -qm "agent: quick fix on main" || echo "-> החוק עבד. ה-commit נחסם."
git checkout -q -- src/discount.js
pause

say "חוק 2: הסוכן עובד נכון על branch, אבל שובר לוגיקה"
git checkout -qb feature/bigger-discount
sed -i.bak 's/0.9/0.5/' src/discount.js && rm -f src/discount.js.bak
git commit -qam "agent: change discount to 50%"
git log --oneline -1
echo "מריצים טסטים (כמו ש-CI יריץ על ה-PR):"
npm test --silent 2>&1 | grep -E "^# (pass|fail)|not ok" || true
echo "-> ב-GitHub: בדיקת CI אדומה + Branch Protection = כפתור Merge חסום."
pause

say "תיקון, טסטים ירוקים, diff לבדיקה אנושית"
git revert --no-edit HEAD >/dev/null
echo "הסוכן מממש את הדרישה האמיתית: 20% הנחה מעל 500, כולל טסט חדש"
cat > src/discount.js <<'J'
export function discount(total) {
  if (total > 500) return total * 0.8;
  return total > 100 ? total * 0.9 : total;
}
J
echo "test('20% off above 500', () => assert.equal(discount(1000), 800));" >> test/discount.test.js
git commit -qam "agent: add 20% tier above 500 with test"
npm test --silent 2>&1 | grep -E "^# (pass|fail)"
git log --oneline
echo
echo "השינוי שהאדם בודק לפני merge:"; git diff main --stat
