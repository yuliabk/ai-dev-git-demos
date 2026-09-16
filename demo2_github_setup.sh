#!/usr/bin/env bash
# Demo 2 - Part B (optional, real GitHub). Requires gh CLI logged in (gh auth login).
# Run from inside the folder created by demo2_protect_main.sh
set -e
REPO="${1:-protect-main-demo}"
OWNER=$(gh api user -q .login)

git checkout -q main
gh repo create "$REPO" --private --source=. --push

# Branch protection: PR required, 1 approval, CI job "test" must pass
gh api -X PUT "repos/$OWNER/$REPO/branches/main/protection" --input - <<'J'
{
  "required_status_checks": { "strict": true, "contexts": ["test"] },
  "enforce_admins": true,
  "required_pull_request_reviews": { "required_approving_review_count": 1 },
  "restrictions": null
}
J
echo "Branch protection הופעל על main."

# A PR with a failing test, to show the red CI gate
git checkout -qb feature/break-discount
sed -i.bak 's/0.9/0.5/' src/discount.js && rm -f src/discount.js.bak
git commit -qam "agent: change discount to 50%"
git push -q --no-verify -u origin feature/break-discount
gh pr create --title "Agent: change discount" --body "Demo PR - CI should fail"
echo "פתחו את ה-PR בדפדפן: gh pr view --web"
