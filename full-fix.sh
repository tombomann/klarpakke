#!/bin/bash
pm2 del all 2>/dev/null || true
cd "$(pwd)/.."  # Up
[ -d klarpakke ] && cd klarpakke
sed -i '' 's/klarpakke-trading/tom-58107/g' app.js
npm i
pm2 start app.js --name bubble-cron
pm2 save
pm2 logs bubble-cron --lines 20
curl localhost:3000/health
