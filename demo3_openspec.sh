#!/usr/bin/env bash
# Demo 3 - OpenSpec on an existing (Brownfield) project: propose -> apply -> archive
# Requires: Node.js 20+, npm install -g @fission-ai/openspec
set -e
pause(){ [ -n "$DEMO_AUTO" ] || read -rp $'\n[Enter] להמשך...' _; }
say(){ printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }
command -v openspec >/dev/null || { echo "התקינו קודם: npm install -g @fission-ai/openspec"; exit 1; }

ROOT="${1:-$HOME/openspec-demo}"
rm -rf "$ROOT" && mkdir -p "$ROOT" && cd "$ROOT"
git init -q -b main && git config user.email demo@example.com && git config user.name Demo

say "1. פרויקט קיים (Brownfield) + התקנת OpenSpec"
openspec init --tools claude,codex --no-animation . >/dev/null
mkdir -p openspec/specs/auth
cat > openspec/specs/auth/spec.md <<'S'
# auth Specification

## Purpose
User login for the demo app.

## Requirements
### Requirement: Password Login
The system SHALL let a user log in with email and password.

#### Scenario: Valid credentials
- **WHEN** a user submits a valid email and password
- **THEN** the user is logged in
S
git add . && git commit -qm "existing project with auth spec"
echo "זה ה-Main Spec - מה שהמערכת עושה היום:"; cat openspec/specs/auth/spec.md
pause

say "2. PROPOSE - שינוי מוצע (בעולם אמיתי: /opsx:propose \"add 2FA\" בתוך הסוכן)"
C=openspec/changes/add-2fa; mkdir -p $C/specs/auth
cat > $C/proposal.md <<'S'
## Why
Password-only login is not enough for admin users.

## What Changes
- Add a one-time code (2FA) step after password login.

## Impact
- Affected specs: auth
S
cat > $C/tasks.md <<'S'
## 1. Implementation
- [ ] 1.1 Add OTP generation
- [ ] 1.2 Add OTP verification step
- [ ] 1.3 Add tests
S
cat > $C/specs/auth/spec.md <<'S'
## ADDED Requirements
### Requirement: Two-Factor Authentication
The system SHALL require a one-time code after a successful password login.

#### Scenario: Correct code
- **WHEN** a user enters the correct one-time code
- **THEN** the user is logged in

#### Scenario: Wrong code
- **WHEN** a user enters a wrong one-time code
- **THEN** access is denied
S
echo "זה ה-Delta Spec - רק מה שמשתנה, לא כל המערכת:"; cat $C/specs/auth/spec.md
openspec list
openspec validate add-2fa --strict
pause

say "3. APPLY - הסוכן מממש לפי tasks.md (בעולם אמיתי: /opsx:apply)"
sed -i.bak 's/- \[ \]/- [x]/' $C/tasks.md && rm -f $C/tasks.md.bak
cat $C/tasks.md
openspec list
pause

say "4. ARCHIVE - ה-Delta מתמזג ל-Main Spec ונשמר בארכיון (/opsx:archive)"
openspec archive add-2fa --yes
echo; echo "Main Spec אחרי המיזוג:"; cat openspec/specs/auth/spec.md
echo; echo "הארכיון (Audit Trail):"; ls openspec/changes/archive
git add . && git commit -qm "archive add-2fa" && git log --oneline
