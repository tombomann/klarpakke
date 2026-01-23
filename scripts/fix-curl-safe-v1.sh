#!/bin/bash
set -euo pipefail
echo "🔧 DEBUG & FIX curl_safe v1"

source scripts/curl-safe.bash 2>/dev/null || echo "No curl-safe yet"

# Test httpbin (ingen auth)
echo "TEST1 httpbin:"
curl_safe https://httpbin.org/json || echo "FAIL expected if bug"

# Fix function (robust parse)
cat > scripts/curl-safe.bash << 'CS2'
curl_safe() {
  local args=("$@")
  local url="${args[-1]}"
  local headers=("${args[@]:1:-1}")
  local resp code
  resp=$(curl -s -w "%{http_code}" -H "${headers[@]}" "$url")
  code="${resp: -3}"
  resp="${resp%???}"
  
  [[ "$code" = "200" ]] || { echo "ERROR $code" >&2; return 1; }
  echo "$resp" | jq empty >/dev/null || { echo "NON-JSON" >&2; return 1; }
  echo "$resp"
}
CS2

source scripts/curl-safe.bash
echo "FIXED. Test: curl_safe https://httpbin.org/json"
curl_safe https://httpbin.org/json
