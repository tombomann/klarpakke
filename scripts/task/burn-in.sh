#!/usr/bin/env bash
set -euo pipefail

N="${1:-5}"
fail=0

mkdir -p logs
out="logs/task-burnin-$(date '+%Y%m%d-%H%M%S').log"

for i in $(seq 1 "$N"); do
  echo "=== round $i/$N ===" | tee -a "$out"
  if ! ./kp deploy 2>&1 | tee -a "$out"; then
    fail=$((fail+1))
  fi
done

echo "Rounds=$N Failures=$fail" | tee -a "$out"
test "$fail" -eq 0
