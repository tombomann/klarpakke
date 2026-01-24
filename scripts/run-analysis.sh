#!/bin/bash
set -euo pipefail

cd ~/klarpakke
source .env.migration

python3 scripts/analyze_signals.py >> logs/analysis-$(date +%Y%m%d).log 2>&1
