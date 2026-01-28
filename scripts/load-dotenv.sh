#!/usr/bin/env bash
# Source this file to safely load a .env file without executing it as shell code.
# Usage:
#   source scripts/load-dotenv.sh .env

set -euo pipefail

ENV_FILE="${1:-.env}"

if [[ ! -f "$ENV_FILE" ]]; then
  return 0 2>/dev/null || exit 0
fi

# Read file line-by-line, tolerate CRLF, ignore comments/blank lines.
# Only accept KEY=VALUE pairs (optionally prefixed with 'export ').
while IFS= read -r line || [[ -n "$line" ]]; do
  # Strip CR (Windows)
  line="${line%$'\r'}"

  # Skip blanks and comments
  [[ -z "$line" ]] && continue
  [[ "$line" =~ ^[[:space:]]*# ]] && continue

  # Allow 'export KEY=VALUE'
  line="${line#export }"

  # Must contain '='
  if [[ "$line" != *"="* ]]; then
    echo "[dotenv] WARN: Skipping invalid line (no '='): $line" >&2
    continue
  fi

  key="${line%%=*}"
  value="${line#*=}"

  # Trim whitespace around key
  key="${key//[[:space:]]/}"

  # Validate key
  if [[ ! "$key" =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
    echo "[dotenv] WARN: Skipping invalid key: $key" >&2
    continue
  fi

  # Remove surrounding quotes (simple cases)
  if [[ "$value" =~ ^".*"$ ]]; then
    value="${value:1:${#value}-2}"
  elif [[ "$value" =~ ^'.*'$ ]]; then
    value="${value:1:${#value}-2}"
  fi

  # Export safely (quoted assignment prevents redirect/operator interpretation)
  export "$key=$value"
done < "$ENV_FILE"
