curl_safe() {
<<<<<<< HEAD
  local args=("$@")
  local url="${args[-1]}"
  local headers=("${args[@]:1:-1}")
  local resp code
  resp=$(curl -s -w "%{http_code}" -H "${headers[@]}" "$url")
  code="${resp: -3}"
  resp="${resp%???}"
  
  [[ "$code" = "200" ]] || { echo "ERROR $code" >&2; return 1; }
  echo "$resp" | jq empty >/dev/null || { echo "NON-JSON" >&2; return 1; }
=======
  local url="$1"; shift
  local resp=$(curl -s -w "\nHTTP%{http_code}" "$@" "$url" 2>/dev/null)
  local http_code="${resp##*$'\n'}"
  resp="${resp%${http_code}*}"
  resp="${resp%?$'\n'}"
  [[ "$http_code" = 200 ]] || { echo "CURL ERROR $http_code" >&2; return 1; }
  echo "$resp" | jq -e . >/dev/null 2>&1 || { echo "NON-JSON" >&2; return 1; }
>>>>>>> 9b22283 (wip: curl safe installer changes)
  echo "$resp"
}
