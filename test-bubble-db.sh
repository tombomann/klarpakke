#!/bin/bash
set -euo pipefail
if [[ -z ${DATABASE_URL:-} ]]; then
  echo "❌ Sett: export DATABASE_URL=\"paste_bubble_url\""
  exit 1
fi
psql "$DATABASE_URL" -c "\dt"  # Tabeller
psql "$DATABASE_URL" -c "CREATE TABLE IF NOT EXISTS AICallLog (id SERIAL PRIMARY KEY, pair TEXT, signal TEXT, confidence INT, created_at TIMESTAMP DEFAULT NOW());"
psql "$DATABASE_URL" -c 'INSERT INTO AICallLog (pair, signal) VALUES ("BTCUSD", "test") RETURNING *;'
echo "✅ Bubble DB OK! Sjekk Data tab → AICallLog"
