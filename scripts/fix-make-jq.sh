#!/bin/bash
set -euo pipefail

# Patch make-team-info.sh for jq numeric error (Make API return?)
sed -i '' 's|jq -e '\''\.'\''|jq -e ". // empty"|' scripts/make-team-info.sh

# Retry
bash scripts/make-team-info.sh
cat .env | grep MAKE || echo "❌ .env missing MAKE_TEAM_ID"
