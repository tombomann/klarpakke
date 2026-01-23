#!/bin/bash
set -euo pipefail

echo "🐳 Local Postgres quickstart (port 5433)"

docker rm -f klarpakke-db 2>/dev/null || true
docker run -d --name klarpakke-db -p 5433:5432 \
  -e POSTGRES_DB=klarpakke \
  -e POSTGRES_USER=user \
  -e POSTGRES_PASSWORD=pass \
  postgres:16-alpine

sleep 5  # Wait startup

export DATABASE_URL="postgres://user:pass@localhost:5433/klarpakke"

echo "🔍 Test connect"
psql "$DATABASE_URL" -c "SELECT 1;"

echo "📋 Schema"
bash scripts/postgres-schema.sh

echo "📊 Test signals"
bash scripts/insert-test-signals.sh

echo "✅ Local DB ready! Use DATABASE_URL=postgres://user:pass@localhost:5433/klarpakke"
echo "Stop: docker rm -f klarpakke-db"
