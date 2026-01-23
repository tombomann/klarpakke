CREATE TABLE IF NOT EXISTS signals (
  id SERIAL PRIMARY KEY,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  symbol VARCHAR(20) NOT NULL,
  signal_type VARCHAR(20) NOT NULL CHECK (signal_type IN ('buy', 'sell', 'hold')),
  price DECIMAL(15,8) NOT NULL,
  confidence DECIMAL(5,4) CHECK (confidence BETWEEN 0 AND 1),
  risk_score DECIMAL(5,4),
  source VARCHAR(50),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'executed', 'failed')),
  executed_at TIMESTAMP WITH TIME ZONE,
  notes TEXT
);

CREATE INDEX IF NOT EXISTS idx_signals_symbol ON signals(symbol);
CREATE INDEX IF NOT EXISTS idx_signals_created_at ON signals(created_at);
CREATE INDEX IF NOT EXISTS idx_signals_status ON signals(status);

INSERT INTO signals (symbol, signal_type, price, confidence, source)
SELECT 'BTCUSD', 'buy', 95000.00, 0.85, 'klarpakke-v1'
WHERE NOT EXISTS (SELECT 1 FROM signals WHERE symbol='BTCUSD' AND source='klarpakke-v1');
