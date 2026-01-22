#!/bin/bash
sed -i '' 's/klarpakke-trading/tom-58107/g' app.js
pm2 restart bubble-cron --update-env
pm2 logs bubble-cron --lines 30 --nostream
