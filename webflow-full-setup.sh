#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Klarpakke Webflow Migration - Full Setup"

# 1️⃣ Create directories
mkdir -p schema make/flows supabase/functions/{risk-check,kill-switch} docs/migration scripts

# 2️⃣ Generate Supabase schema
cat > schema/supabase-core.sql << 'SCHEMA_EOF'
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
SCHEMA_EOF

# 3️⃣ Generate validation script
cat > scripts/check-supabase-schema.sh << 'VALIDATE_EOF'
#!/usr/bin/env bash
set -euo pipefail

: "${SUPABASE_DB_URL:?must set SUPABASE_DB_URL}"

tables=(risk_profiles users aisignal position_tracking daily_risk_meter ai_call_log kill_switch_events)

echo "🔍 Validating Supabase schema..."

for t in "${tables[@]}"; do
  echo "  ✓ Checking: $t"
  psql "$SUPABASE_DB_URL" -c "\d+ $t" >/dev/null || {
    echo "❌ ERROR: Table $t missing"
    exit 1
  }
done

echo "✅ All tables exist"
VALIDATE_EOF

chmod +x scripts/check-supabase-schema.sh

# 4️⃣ Generate Make scenario
cat > make/flows/signal-approve.json << 'MAKE_EOF'
{
  "name": "Klarpakke: Signal Approve",
  "flow": [
    {
      "id": 1,
      "module": "gateway:WebhookRespond"
    },
    {
      "id": 2,
      "module": "supabase:Select",
      "mapper": {
        "table": "aisignal"
      }
    }
  ]
}
MAKE_EOF

# 5️⃣ Generate migration doc
cat > docs/migration/webflow-spec.md << 'DOC_EOF'
# Klarpakke Webflow Migration

## Stack
- UI: Webflow
- DB: Supabase
- Logic: Make + Edge Functions

## Risk Rules (UNCHANGED)
- 0.25% risk per trade
- Max 2 positions
- Daily: -2%/-4%
- Weekly: -5%/-8%
DOC_EOF

echo ""
echo "✅ Setup complete!"
echo ""
tree -L 2 schema make supabase docs scripts 2>/dev/null || find schema make supabase docs scripts -type f
echo ""
echo "🔜 Next: Deploy schema to Supabase"

