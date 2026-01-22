#!/bin/bash
KEY="your_real_key_here"  # Paste!
ssh opc@VM "
rm -rf ~/klarpakke
git clone https://github.com/tombomann/klarpakke.git ~/klarpakke
cd ~/klarpakke
npm i express axios node-cron pm2 -g
export BUBBLE_API_KEY='$KEY'
pm2 start app.js --name bubble-cron
pm2 save
pm2 logs bubble-cron --lines 10
"
