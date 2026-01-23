#!/bin/bash
set -euo pipefail

echo "🔧 Generating Make scenario blueprints..."
mkdir -p make/flows

# 2. Signal Reject
cat > make/flows/signal-reject.json << 'SCENARIO_2'
{
  "name": "Klarpakke: Signal Reject",
  "flow": [
    {
      "id": 1,
      "module": "gateway:WebhookRespond",
      "version": 1,
      "parameters": {
        "status": "200",
        "body": "{{1.symbol}} rejected: {{1.reject_reason}}"
      },
      "mapper": {},
      "metadata": {
        "designer": {"x": 0, "y": 0}
      }
    },
    {
      "id": 2,
      "module": "postgresql:insertRow",
      "version": 1,
      "parameters": {
        "connection": "supabase",
        "schema": "public",
        "table": "ai_call_log"
      },
      "mapper": {
        "symbol": "{{1.symbol}}",
        "action": "reject",
        "reason": "{{1.reject_reason}}",
        "timestamp": "{{now}}"
      },
      "metadata": {
        "designer": {"x": 300, "y": 0}
      }
    }
  ],
  "metadata": {
    "version": 1
  }
}
SCENARIO_2

# 3. Kill Switch
cat > make/flows/kill-switch.json << 'SCENARIO_3'
{
  "name": "Klarpakke: Kill Switch",
  "flow": [
    {
      "id": 1,
      "module": "gateway:WebhookRespond",
      "version": 1,
      "parameters": {
        "status": "200",
        "body": "Kill switch activated"
      }
    },
    {
      "id": 2,
      "module": "postgresql:insertRow",
      "version": 1,
      "parameters": {
        "connection": "supabase",
        "schema": "public",
        "table": "kill_switch_events"
      },
      "mapper": {
        "user_id": "{{1.user_id}}",
        "reason": "{{1.reason}}",
        "triggered_at": "{{now}}"
      }
    },
    {
      "id": 3,
      "module": "postgresql:updateRow",
      "version": 1,
      "parameters": {
        "connection": "supabase",
        "schema": "public",
        "table": "position_tracking",
        "condition": "status = 'OPEN'"
      },
      "mapper": {
        "status": "CLOSED",
        "closed_at": "{{now}}",
        "close_reason": "KILL_SWITCH"
      }
    }
  ]
}
SCENARIO_3

# 4. Risk Monitor (Cron)
cat > make/flows/risk-monitor.json << 'SCENARIO_4'
{
  "name": "Klarpakke: Risk Monitor",
  "flow": [
    {
      "id": 1,
      "module": "gateway:Schedule",
      "version": 1,
      "parameters": {
        "schedule": "*/5 * * * *"
      }
    },
    {
      "id": 2,
      "module": "postgresql:selectRows",
      "version": 1,
      "parameters": {
        "connection": "supabase",
        "schema": "public",
        "table": "daily_risk_meter"
      },
      "mapper": {
        "condition": "date = current_date"
      }
    },
    {
      "id": 3,
      "module": "util:SetVariable",
      "version": 1,
      "mapper": {
        "daily_loss": "{{2.daily_loss}}",
        "weekly_loss": "{{2.weekly_loss}}",
        "daily_limit": "-1000",
        "weekly_limit": "-3000"
      }
    },
    {
      "id": 4,
      "module": "util:Filter",
      "version": 1,
      "filter": {
        "conditions": [
          ["{{3.daily_loss}}", "numeric:less", "{{3.daily_limit}}"],
          ["{{3.weekly_loss}}", "numeric:less", "{{3.weekly_limit}}"]
        ],
        "operator": "or"
      }
    },
    {
      "id": 5,
      "module": "http:ActionSendData",
      "version": 1,
      "parameters": {
        "url": "https://YOUR_WEBHOOK_URL/kill-switch",
        "method": "POST"
      },
      "mapper": {
        "reason": "Risk limit breached: Daily {{3.daily_loss}} / Weekly {{3.weekly_loss}}"
      }
    }
  ]
}
SCENARIO_4

# 5. Daily Reset (Cron)
cat > make/flows/daily-reset.json << 'SCENARIO_5'
{
  "name": "Klarpakke: Daily Reset",
  "flow": [
    {
      "id": 1,
      "module": "gateway:Schedule",
      "version": 1,
      "parameters": {
        "schedule": "0 0 * * *"
      }
    },
    {
      "id": 2,
      "module": "postgresql:insertRow",
      "version": 1,
      "parameters": {
        "connection": "supabase",
        "schema": "public",
        "table": "daily_risk_meter"
      },
      "mapper": {
        "date": "{{now}}",
        "daily_loss": "0",
        "daily_trades": "0",
        "created_at": "{{now}}"
      }
    },
    {
      "id": 3,
      "module": "postgresql:insertRow",
      "version": 1,
      "parameters": {
        "connection": "supabase",
        "schema": "public",
        "table": "ai_call_log"
      },
      "mapper": {
        "action": "daily_reset",
        "timestamp": "{{now}}",
        "details": "Risk meter reset for new trading day"
      }
    }
  ]
}
SCENARIO_5

echo ""
echo "✅ Generated 4 new Make scenarios:"
ls -1 make/flows/*.json | while read f; do echo "  ✓ $(basename $f)"; done
echo ""
echo "📊 Total scenarios: $(ls -1 make/flows/*.json | wc -l)"
