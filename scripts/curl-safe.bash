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
