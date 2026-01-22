#!/bin/bash
read -p "BUBBLE_API_KEY: " KEY
curl -X POST "https://klarpakke-trading.bubbleapps.io/version-test/api/1.1/obj/Signal" \\
  -H "Authorization: Bearer $KEY" \\
  -H "Content-Type: application/json" \\
  -d '{
    "symbol": "BTC",
    "price": 90000,
    "rsi": 38,
    "signal": "HOLD",
    "conf": 85,
    "ts": "2026-01-22T16:45:00Z"
  }' -v
echo "200 OK? Fields match. Else: Unrecognized field → edit Bubble Data."
