#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(pwd)"
APP_DIR="$REPO_ROOT/app"
REPORT="/tmp/klarpakke_deploy_report.txt"
: > "$REPORT"

echo "START: $(date)" | tee -a "$REPORT"

# 1 Backup existing files
echo "Backing up vercel.json and .vercelignore" | tee -a "$REPORT"
[ -f vercel.json ] && cp vercel.json vercel.json.bak && echo "Backed up vercel.json" | tee -a "$REPORT" || echo "No vercel.json found" | tee -a "$REPORT"
[ -f .vercelignore ] && mv .vercelignore .vercelignore.bak && echo "Moved .vercelignore to .vercelignore.bak" | tee -a "$REPORT" || echo "No .vercelignore found" | tee -a "$REPORT"

# 2 Write recommended vercel.json
cat > vercel.json <<'JSON'
{
  "framework": "nextjs",
  "root": "app",
  "installCommand": "cd app && npm ci",
  "buildCommand": "cd app && npm run build"
}
JSON
echo "Wrote vercel.json with root: app" | tee -a "$REPORT"

# 3 Commit change (non-destructive empty commit allowed)
git add vercel.json || true
git commit -m "ci: set vercel root to app" || echo "No changes to commit or commit failed" | tee -a "$REPORT"
git push origin main || echo "git push failed; ensure you have network and permissions" | tee -a "$REPORT"

# 4 Build locally in app
if [ -d "$APP_DIR" ]; then
  echo "Installing and building in $APP_DIR" | tee -a "$REPORT"
  cd "$APP_DIR"
  npm ci 2>&1 | tee -a "$REPORT"
  npm run build 2>&1 | tee -a "$REPORT"
  echo "Local build finished" | tee -a "$REPORT"
else
  echo "ERROR: app directory not found at $APP_DIR" | tee -a "$REPORT"
  exit 1
fi

# 5 Deploy from app with Vercel
cd "$APP_DIR"
echo "Deploying to Vercel from $APP_DIR" | tee -a "$REPORT"
VERCEL_OUTPUT="/tmp/vercel_deploy_output.txt"
vercel --prod --yes --force --debug 2>&1 | tee "$VERCEL_OUTPUT" | tee -a "$REPORT"

# 6 Extract production URL
PROD_URL=$(grep -Eo 'https://[a-zA-Z0-9._-]+\.vercel\.app' "$VERCEL_OUTPUT" | head -1 || true)
echo "Detected production URL: $PROD_URL" | tee -a "$REPORT"

# 7 Test endpoints
echo "Testing endpoints with curl -I" | tee -a "$REPORT"
echo "Production URL:" | tee -a "$REPORT"
if [ -n "$PROD_URL" ]; then
  curl -I "$PROD_URL" 2>&1 | tee -a "$REPORT"
else
  echo "No production URL found in deploy output" | tee -a "$REPORT"
fi

echo "Alias elbatt-chatbot.vercel.app:" | tee -a "$REPORT"
curl -I "https://elbatt-chatbot.vercel.app" 2>&1 | tee -a "$REPORT" || true

echo "Default klarpakke.vercel.app:" | tee -a "$REPORT"
curl -I "https://klarpakke.vercel.app" 2>&1 | tee -a "$REPORT" || true

# 8 If PROD_URL returns 200, offer to re-alias
if [ -n "$PROD_URL" ]; then
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$PROD_URL" || echo "000")
  echo "Production URL HTTP status: $STATUS" | tee -a "$REPORT"
  if [ "$STATUS" = "200" ]; then
    echo ""
    echo "Production URL is healthy (200)."
    read -p "Do you want to re-alias elbatt-chatbot.vercel.app to $PROD_URL now? [y/N] " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
      echo "Removing old alias (if any) and setting new alias" | tee -a "$REPORT"
      vercel alias rm elbatt-chatbot.vercel.app --yes 2>&1 | tee -a "$REPORT" || true
      vercel alias set "$PROD_URL" elbatt-chatbot.vercel.app --yes 2>&1 | tee -a "$REPORT" || true
      echo "Alias set. Waiting 10s then testing alias" | tee -a "$REPORT"
      sleep 10
      curl -I "https://elbatt-chatbot.vercel.app" 2>&1 | tee -a "$REPORT" || true
    else
      echo "Skipping re-alias. You can run the alias commands manually later." | tee -a "$REPORT"
    fi
  else
    echo "Production URL did not return 200. Skipping re-alias." | tee -a "$REPORT"
  fi
fi

# 9 Save deploy logs and finish
echo "Saved deploy output to $VERCEL_OUTPUT and report to $REPORT"
echo "END: $(date)" | tee -a "$REPORT"

# 10 Restore .vercelignore if it was moved
if [ -f "$REPO_ROOT/.vercelignore.bak" ]; then
  mv "$REPO_ROOT/.vercelignore.bak" "$REPO_ROOT/.vercelignore"
  echo "Restored original .vercelignore" | tee -a "$REPORT"
fi

echo "Script finished. Review $REPORT for details."
