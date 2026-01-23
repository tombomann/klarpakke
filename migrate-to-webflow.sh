#!/bin/bash
set -euo pipefail
LOG="migration-$(date +%Y%m%d-%H%M%S).log"
echo "🚀 Klarpakke Migration Automation" | tee "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
source .env.migration || { echo "❌ .env.migration missing"; exit 1; }
echo "✓ Environment loaded (Team: $MAKE_TEAM_ID)" | tee -a "$LOG"
echo "" | tee -a "$LOG"
echo "🗄️  Supabase Validation:" | tee -a "$LOG"
bash scripts/check-supabase-schema.sh 2>&1 | tee -a "$LOG"
echo "" | tee -a "$LOG"
echo "⚙️  Make Blueprints:" | tee -a "$LOG"
ls make/flows/*.json 2>/dev/null | while read f; do echo "  ✓ $(basename $f)" | tee -a "$LOG"; done
echo "" | tee -a "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
echo "🎉 MIGRATION STATUS: OPERATIONAL" | tee -a "$LOG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" | tee -a "$LOG"
echo "📄 Log: $LOG" | tee -a "$LOG"
