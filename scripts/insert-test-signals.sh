#!/bin/bash
set -euo pipefail

psql "$DATABASE_URL" -c "
INSERT INTO signals (symbol, signal_type, confidence, price, reason, risk_score, status)
VALUES 
  ('BTCUSDT', 'LONG', 0.85, 95000.0, 'EMA cross + vol breakout', 0.12, 'approved'),
  ('ETHUSDT', 'SHORT', 0.72, 3200.0, 'RSI overbought', 0.25, 'pending')
ON CONFLICT DO NOTHING;

SELECT COUNT(*) as signal_count, AVG(confidence) as avg_conf FROM signals;
"
