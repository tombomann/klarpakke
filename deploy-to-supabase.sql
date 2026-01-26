-- Klarpakke Database Setup
-- Deploy this in Supabase SQL Editor:
-- https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor

-- ============================================
-- STEP 1: Clean slate (drop existing tables)
-- ============================================
DROP TABLE IF EXISTS ai_calls CASCADE;
DROP TABLE IF EXISTS daily_risk_meter CASCADE;
DROP TABLE IF EXISTS signals CASCADE;
DROP TABLE IF EXISTS positions CASCADE;

-- Drop old triggers/functions
DROP TRIGGER IF EXISTS trigger_update_risk_meter ON positions;
DROP FUNCTION IF EXISTS update_risk_meter();

-- ============================================
-- STEP 2: Create tables from scratch
-- ============================================

-- POSITIONS: Åpne og lukkede trading posisjoner
CREATE TABLE positions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  symbol TEXT NOT NULL,
  entry_price NUMERIC NOT NULL,
  quantity NUMERIC NOT NULL,
  current_price NUMERIC,
  pnl_percent NUMERIC,
  pnl_usd NUMERIC,
  status TEXT DEFAULT 'open' CHECK (status IN ('open', 'closed')),
  entry_time TIMESTAMP DEFAULT now(),
  exit_time TIMESTAMP,
  signal_id UUID,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_positions_user_id ON positions(user_id);
CREATE INDEX idx_positions_status ON positions(status);
CREATE INDEX idx_positions_symbol ON positions(symbol);

-- SIGNALS: AI-genererte trading signaler
CREATE TABLE signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol TEXT NOT NULL,
  direction TEXT NOT NULL CHECK (direction IN ('BUY', 'SELL', 'HOLD')),
  confidence NUMERIC DEFAULT 0.5 CHECK (confidence BETWEEN 0 AND 1),
  reason TEXT,
  ai_model TEXT DEFAULT 'perplexity-sonar',
  created_at TIMESTAMP DEFAULT now(),
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected', 'executed')),
  approved_at TIMESTAMP,
  approved_by TEXT,
  executed_at TIMESTAMP
);

CREATE INDEX idx_signals_status ON signals(status);
CREATE INDEX idx_signals_symbol ON signals(symbol);
CREATE INDEX idx_signals_created_at ON signals(created_at DESC);

-- DAILY_RISK_METER: Daglig risiko tracking
CREATE TABLE daily_risk_meter (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE DEFAULT CURRENT_DATE,
  total_risk_usd NUMERIC DEFAULT 0,
  max_risk_allowed NUMERIC DEFAULT 5000,
  risk_percent NUMERIC GENERATED ALWAYS AS (
    CASE WHEN max_risk_allowed > 0 
      THEN (total_risk_usd / max_risk_allowed) * 100 
      ELSE 0 
    END
  ) STORED,
  active_positions_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

CREATE UNIQUE INDEX idx_risk_meter_date ON daily_risk_meter(date);

-- AI_CALLS: Logging av alle AI API-kall
CREATE TABLE ai_calls (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  endpoint TEXT NOT NULL,
  model TEXT DEFAULT 'sonar-pro',
  prompt TEXT,
  response TEXT,
  tokens_in INT,
  tokens_out INT,
  cost_usd NUMERIC,
  status INT DEFAULT 200,
  latency_ms INT,
  created_at TIMESTAMP DEFAULT now()
);

CREATE INDEX idx_ai_calls_created_at ON ai_calls(created_at DESC);
CREATE INDEX idx_ai_calls_model ON ai_calls(model);

-- ============================================
-- STEP 3: Row-Level Security (RLS)
-- ============================================
ALTER TABLE positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_risk_meter ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_calls ENABLE ROW LEVEL SECURITY;

-- Public read policies
CREATE POLICY "Allow public read positions" 
  ON positions FOR SELECT USING (true);

CREATE POLICY "Allow public read signals" 
  ON signals FOR SELECT USING (true);

CREATE POLICY "Allow public read risk" 
  ON daily_risk_meter FOR SELECT USING (true);

CREATE POLICY "Allow public read ai_calls" 
  ON ai_calls FOR SELECT USING (true);

-- Insert/update policies (for Make.com with secret key)
CREATE POLICY "Allow insert positions" 
  ON positions FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update positions" 
  ON positions FOR UPDATE USING (true);

CREATE POLICY "Allow insert signals" 
  ON signals FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update signals" 
  ON signals FOR UPDATE USING (true);

CREATE POLICY "Allow insert risk_meter" 
  ON daily_risk_meter FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow update risk_meter" 
  ON daily_risk_meter FOR UPDATE USING (true);

CREATE POLICY "Allow insert ai_calls" 
  ON ai_calls FOR INSERT WITH CHECK (true);

-- ============================================
-- STEP 4: Functions & Triggers
-- ============================================
CREATE OR REPLACE FUNCTION update_risk_meter()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO daily_risk_meter (date, total_risk_usd, active_positions_count)
  VALUES (
    CURRENT_DATE,
    (SELECT COALESCE(SUM(ABS(pnl_usd)), 0) FROM positions WHERE status = 'open'),
    (SELECT COUNT(*) FROM positions WHERE status = 'open')
  )
  ON CONFLICT (date) DO UPDATE
  SET 
    total_risk_usd = EXCLUDED.total_risk_usd,
    active_positions_count = EXCLUDED.active_positions_count,
    updated_at = now();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_risk_meter
AFTER INSERT OR UPDATE OR DELETE ON positions
FOR EACH ROW
EXECUTE FUNCTION update_risk_meter();

-- ============================================
-- STEP 5: Initial data
-- ============================================
INSERT INTO daily_risk_meter (date, total_risk_usd, max_risk_allowed, active_positions_count)
VALUES (CURRENT_DATE, 0, 5000, 0)
ON CONFLICT (date) DO NOTHING;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================
-- Run these after to verify:
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;
-- SELECT * FROM daily_risk_meter;
