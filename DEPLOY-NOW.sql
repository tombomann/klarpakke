-- ============================================
-- KLARPAKKE DATABASE SETUP
-- Copy-paste denne i Supabase SQL Editor
-- https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor
-- ============================================

-- STEP 1: Drop alt (CASCADE fjerner alle avhengigheter)
DROP TABLE IF EXISTS positions CASCADE;
DROP TABLE IF EXISTS signals CASCADE;
DROP TABLE IF EXISTS daily_risk_meter CASCADE;
DROP TABLE IF EXISTS ai_calls CASCADE;

-- STEP 2: Create positions
CREATE TABLE positions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id TEXT NOT NULL,
  symbol TEXT NOT NULL,
  entry_price NUMERIC NOT NULL,
  quantity NUMERIC NOT NULL,
  current_price NUMERIC,
  pnl_percent NUMERIC,
  pnl_usd NUMERIC,
  status TEXT DEFAULT 'open',
  entry_time TIMESTAMP DEFAULT now(),
  exit_time TIMESTAMP,
  signal_id UUID,
  created_at TIMESTAMP DEFAULT now()
);

-- STEP 3: Create signals
CREATE TABLE signals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  symbol TEXT NOT NULL,
  direction TEXT NOT NULL,
  confidence NUMERIC DEFAULT 0.5,
  reason TEXT,
  ai_model TEXT DEFAULT 'perplexity-sonar',
  status TEXT DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT now()
);

-- STEP 4: Create daily_risk_meter
CREATE TABLE daily_risk_meter (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE DEFAULT CURRENT_DATE,
  total_risk_usd NUMERIC DEFAULT 0,
  max_risk_allowed NUMERIC DEFAULT 5000,
  active_positions_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT now()
);

-- STEP 5: Create ai_calls
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
  created_at TIMESTAMP DEFAULT now()
);

-- STEP 6: RLS policies (public read)
ALTER TABLE positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE signals ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_risk_meter ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_calls ENABLE ROW LEVEL SECURITY;

CREATE POLICY "public_read_positions" ON positions FOR SELECT USING (true);
CREATE POLICY "public_read_signals" ON signals FOR SELECT USING (true);
CREATE POLICY "public_read_risk" ON daily_risk_meter FOR SELECT USING (true);
CREATE POLICY "public_read_ai" ON ai_calls FOR SELECT USING (true);

CREATE POLICY "auth_write_positions" ON positions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "auth_write_signals" ON signals FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "auth_write_risk" ON daily_risk_meter FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "auth_write_ai" ON ai_calls FOR ALL USING (true) WITH CHECK (true);

-- STEP 7: Seed data
INSERT INTO daily_risk_meter (date, total_risk_usd, max_risk_allowed, active_positions_count)
VALUES (CURRENT_DATE, 0, 5000, 0);

-- DONE!
SELECT '✅ Database setup complete!' AS status,
       'Tables created: positions, signals, daily_risk_meter, ai_calls' AS info;
