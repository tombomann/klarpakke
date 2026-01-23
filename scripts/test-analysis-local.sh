#!/bin/bash
set -euo pipefail

cd ~/klarpakke
source .env.migration

export SUPABASE_PROJECT_ID
export SUPABASE_SERVICE_ROLE_KEY

echo "🧪 Testing analysis locally..."
python3 scripts/analyze_signals.py
