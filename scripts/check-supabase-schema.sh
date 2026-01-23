#!/usr/bin/env bash
set -euo pipefail

: "${SUPABASE_DB_URL:?must set SUPABASE_DB_URL}"

tables=(risk_profiles users aisignal position_tracking daily_risk_meter ai_call_log kill_switch_events)

echo "🔍 Validating Supabase schema..."

for t in "${tables[@]}"; do
  echo "  ✓ Checking: $t"
  psql "$SUPABASE_DB_URL" -c "\d+ $t" >/dev/null || {
    echo "❌ ERROR: Table $t missing"
    exit 1
  }
done

echo "✅ All tables exist"
