-- Klarpakke Supabase Schema (Webflow Migration)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE risk_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL UNIQUE,
  daily_soft_stop_pct NUMERIC(5,2) NOT NULL,
  daily_hard_stop_pct NUMERIC(5,2) NOT NULL,
  weekly_soft_stop_pct NUMERIC(5,2) NOT NULL,
  weekly_hard_stop_pct NUMERIC(5,2) NOT NULL,
  max_positions INT NOT NULL DEFAULT 2,
  risk_per_trade_pct NUMERIC(5,2) NOT NULL DEFAULT 0.25,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO risk_profiles (name, daily_soft_stop_pct, daily_hard_stop_pct, weekly_soft_stop_pct, weekly_hard_stop_pct)
VALUES ('STANDARD_2', 2.00, 4.00, 5.00, 8.00);

CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email TEXT UNIQUE NOT NULL,
  tier TEXT NOT NULL CHECK (tier IN ('FREE', 'PRO', 'ELITE')),
  risk_profile_id UUID REFERENCES risk_profiles(id),
  account_equity_usd NUMERIC(12,2) DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE aisignal (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  pair TEXT NOT NULL,
  signal_type TEXT NOT NULL CHECK (signal_type IN ('BUY', 'SELL', 'HOLD')),
  confidence_score INT CHECK (confidence_score BETWEEN 0 AND 100),
  status TEXT DEFAULT 'PENDING',
  risk_usd NUMERIC(12,2),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE position_tracking (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  signal_id UUID REFERENCES aisignal(id),
  pair TEXT NOT NULL,
  entry_price NUMERIC(18,8) NOT NULL,
  status TEXT DEFAULT 'OPEN',
  opened_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE daily_risk_meter (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  daily_pnl_pct NUMERIC(5,2) DEFAULT 0,
  weekly_pnl_pct NUMERIC(5,2) DEFAULT 0,
  state TEXT DEFAULT 'NORMAL',
  close_only BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, date)
);

CREATE TABLE ai_call_log (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  prompt_tokens INT,
  completion_tokens INT,
  cost_usd NUMERIC(10,6),
  timestamp TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE kill_switch_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES users(id),
  trigger_reason TEXT NOT NULL,
  positions_closed INT,
  triggered_at TIMESTAMPTZ DEFAULT NOW()
);
