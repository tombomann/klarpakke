#!/bin/bash
set -euo pipefail
echo "🛠️ Curl-safe installer (permanent fix)"

mkdir -p scripts docs/automation

cat > scripts/curl-safe.bash << 'CS_EOF'
curl_safe() {
  local url="$1"; shift
  local resp=$(curl -s -w "\nHTTP%{http_code}" "$@" "$url" 2>/dev/null)
  local http_code="${resp##*$'\n'}"
  resp="${resp%${http_code}*}"
  resp="${resp%?$'\n'}"
  [[ "$http_code" = 200 ]] || { echo "CURL ERROR $http_code" >&2; return 1; }
  echo "$resp" | jq -e . >/dev/null 2>&1 || { echo "NON-JSON" >&2; return 1; }
  echo "$resp"
}
CS_EOF

cat >> docs/automation/DECISIONS.md << 'DEC_EOF'

## Curl Standard (permanent)
- source scripts/curl-safe.bash i alle scripts
- USERS=$(curl_safe URL -H ...)
DEC_EOF

chmod +x scripts/curl-safe.bash scripts/install-curl-safe.sh
echo "✅ Installed! Run: bash scripts/install-curl-safe.sh"
