#!/bin/bash
# Klarpakke curl_safe v3: NO ARRAYS, simple parse
curl_safe() {
  local url="$1" header1="$2" rest="$3"
  local resp=$(curl -s -w "%{http_code}" "$header1" "$rest" "$url" 2>/dev/null || echo "FAIL500")
  local code="${resp: -3}"
  local body="${resp%???}"
  
  if [[ "$code" != "200" ]]; then
    echo "CURL ERROR $code" >&2
    return 1
  fi
  if ! echo "$body" | jq empty >/dev/null 2>&1; then
    echo "NON-JSON" >&2
    return 1
  fi
  echo "$body"
}
