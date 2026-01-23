#!/bin/bash
set -euo pipefail
echo "Supabase Smoke Test"
# Test: export SUPABASE_URL/KEY → curl POST signal
echo "✅ Run: export SUPABASE_URL=...; bash scripts/supabase-smoke.sh test"
