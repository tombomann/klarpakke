#!/bin/bash
# AI-SOLO KLARPAKKE → 18 MIN PRODUCTION

echo "🚀 Step 1: Make.com (manual 10 min)"
echo "1. make.com → Scenario 'Klarpakke Master'"
echo "2. Schedule Tue 10AM → Perplexity → HTTP Bubble → Slack"
echo "3. Run once → Copy webhook URL below"

read -p "Make.com webhook ready? URL: " MAKE_WEBHOOK

echo "Step 2: Bubble webhook (5 min)"
# Manual Bubble steps here

echo "Step 3: Cron jobs"
(crontab -l 2>/dev/null; echo "0 10 * * 2 curl -X POST $MAKE_WEBHOOK") | crontab -

echo "✅ SOLO PRODUCTION LIVE"
echo "Monitor: make.com dashboard + crontab -l"
