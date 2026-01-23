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
