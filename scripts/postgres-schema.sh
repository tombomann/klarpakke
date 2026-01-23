#!/bin/bash
set -euo pipefail

DATABASE_URL="${DATABASE_URL:?Missing DATABASE_URL}"

echo "🔍 Test DB connect..."
psql "$DATABASE_URL" -c "SELECT 1;" || { echo "❌ DB connect failed"; exit 1; }

echo "📋 Create tables (idempotent)..."

psql "$DATABASE_URL" -c "
CREATE TABLE IF NOT EXISTS signals (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT NOW(),
  symbol VARCHAR(20) NOT NULL,
  signal_type VARCHAR(10) CHECK (signal_type IN ('LONG','SHORT')) NOT NULL,
  confidence DECIMAL(3,2) CHECK (confidence BETWEEN 0 AND 1),
  price DECIMAL(10,2),
  reason TEXT,
  risk_score DECIMAL(3,2),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected','executed'))
);

CREATE TABLE IF NOT EXISTS positions (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP DEFAULT NOW(),
  signal_id INT REFERENCES signals(id),
  symbol VARCHAR(20) NOT NULL,
  side VARCHAR(10) CHECK (side IN ('long','short')),
  size DECIMAL(10,4),
  entry_price DECIMAL(10,2),
  status VARCHAR(20) DEFAULT 'open'
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_signals_status ON signals(status);
CREATE INDEX IF NOT EXISTS idx_signals_symbol ON signals(symbol);
"

echo "✅ Schema OK. Tables:"
psql "$DATABASE_URL" -c "\dt signals positions"
