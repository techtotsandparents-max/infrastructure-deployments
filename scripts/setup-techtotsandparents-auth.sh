#!/bin/bash
# ============================================================
# setup-techtotsandparents-auth.sh
# 
# Configures Git to push to techtotsandparents-max repos
# using a Personal Access Token (PAT).
#
# Usage:
#   ./scripts/setup-techtotsandparents-auth.sh <YOUR_PAT_TOKEN>
#
# To generate a PAT:
#   1. Log into GitHub as techtotsandparents-max
#   2. Go to: https://github.com/settings/tokens/new
#   3. Name: "infrastructure-deployments push"
#   4. Expiration: 90 days
#   5. Scopes: check "repo" (full control of private repos)
#   6. Click "Generate token"
#   7. Copy the token and run this script with it
# ============================================================

set -euo pipefail

TOKEN="${1:-}"

if [ -z "$TOKEN" ]; then
  echo "❌ Usage: $0 <GITHUB_PAT_TOKEN>"
  echo ""
  echo "Generate a token at: https://github.com/settings/tokens/new"
  echo "  - Log in as: techtotsandparents-max"
  echo "  - Scopes needed: repo"
  exit 1
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# Store the token in macOS Keychain under a unique service name
# so it doesn't conflict with rahul-tripathi_iis credentials
security delete-internet-password -s "github.com" -a "techtotsandparents-max" 2>/dev/null || true
security add-internet-password \
  -s "github.com" \
  -a "techtotsandparents-max" \
  -w "$TOKEN" \
  -r "htps" \
  -l "techtotsandparents-max@github.com" \
  -T "" \
  2>/dev/null || true

# Update the remote URL to embed the username (token auth via credential helper)
cd "$REPO_ROOT"
git remote set-url origin "https://techtotsandparents-max@github.com/techtotsandparents-max/infrastructure-deployments.git"

echo "✅ Authentication configured!"
echo ""
echo "Testing push access..."
git push --dry-run origin main 2>&1 && echo "✅ Push access confirmed!" || echo "❌ Push failed - check your token"
