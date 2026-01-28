#!/usr/bin/env bash
set -euo pipefail

# ... (behold toppen av filen)

echo "[deploy-functions] Deploying functions…"

for d in supabase/functions/*; do
  if [ -d "$d" ]; then
    func_name=$(basename "$d")
    
    # SKIPPE mapper som starter med _ eller . (f.eks _shared)
    if [[ "$func_name" == _* ]] || [[ "$func_name" == .* ]]; then
      echo "[deploy-functions] Skipping shared/hidden dir: $func_name"
      continue
    fi

    echo "[deploy-functions] → $func_name"
    supabase functions deploy "$func_name" --no-verify-jwt
  fi
done

