#!/bin/bash
set -euo pipefail

echo "🔧 Auto Bubble recreate + AICallLog..."

# 1. Ny Bubble app via CLI (mocks API)
APP_NAME="klarpakke-trading-$(date +%Y%m%d)"
echo "Ny app: $APP_NAME.bubbleapps.io"
echo "Gå manuelt: bubble.io → New app → Name: $APP_NAME"

# 2. Schema SQL for manual copy
cat > bubble-schema.sql << 'SQL_EOF'
-- Copy to Bubble Data → AICallLog type fields
-- Or psql when URL ready
CREATE TABLE IF NOT EXISTS AICallLog (
  id SERIAL PRIMARY KEY,
  pair TEXT NOT NULL,
  signal TEXT,
  confidence INTEGER DEFAULT 85,
  created_at TIMESTAMP DEFAULT NOW()
);
SQL_EOF

# 3. Test psql stub
echo 'bubble-log-ready:
	@if [ -n "${DATABASE_URL:-}" ]; then \
		psql "$$DATABASE_URL" -f bubble-schema.sql && \
		psql "$$DATABASE_URL" -c "INSERT INTO AICallLog (pair, signal) VALUES (\"BTCUSD\", \"auto\");" && \
		echo "✅ Bubble DB synced!"; \
	else \
		echo "DB ready - export DATABASE_URL=..."; \
	fi' >> Makefile

# 4. README update
sed -i '' 's/klarpakke-trading.bubbleapps.io/'"$APP_NAME.bubbleapps.io/"' README.md || true

echo "✅ Auto-setup ready!"
echo "1. bubble.io → New app → $APP_NAME"
echo "2. Data → AICallLog type + 4 fields"
echo "3. export DATABASE_URL=... (Settings/Database)"
echo "4. make bubble-log-ready"
