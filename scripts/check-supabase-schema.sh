#!/bin/bash
set -euo pipefail

# Load environment if not set
if [[ -z "${SUPABASE_DB_URL:-}" ]]; then
  [[ -f .env.migration ]] && source .env.migration
fi

echo "🔍 Validating Supabase schema..."

TABLES=("risk_profiles" "users" "aisignal" "position_tracking" "daily_risk_meter" "ai_call_log" "kill_switch_events")

for table in "${TABLES[@]}"; do
  echo -n "  ✓ Checking: $table"
  if psql "$SUPABASE_DB_URL" -tc "SELECT 1 FROM $table LIMIT 1" >/dev/null 2>&1; then
    echo " ✅"
  else
    echo " ❌"; exit 1
  fi
done
echo "✅ All tables exist"
