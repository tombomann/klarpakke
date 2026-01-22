#!/bin/bash
set -e
echo "1. Update app.js w/ full err log"
cat > app.js << 'APP'
const express = require('express');
const cron = require('node-cron');
const axios = require('axios');
const app = express();
app.get('/health', (req, res) => res.json({status: 'OK', ts: new Date().toISOString()}));
cron.schedule('*/5 * * * *', async () => {
  const price = 90000; // Mock, replace w/ API
  const data = {symbol: 'BTC', price, rsi: 38, signal: 'HOLD', conf: 85, ts: new Date().toISOString()};
  const BUBBLE_URL = process.env.BUBBLE_URL || 'https://klarpakke-trading.bubbleapps.io/version-test/api/1.1/obj/Signal';
  if (process.env.BUBBLE_API_KEY) {
    try {
      await axios.post(BUBBLE_URL, data, {headers: {'Authorization': `Bearer ${process.env.BUBBLE_API_KEY}`}});
      console.log('Posted OK:', data);
    } catch (e) {
      console.log('Err full:', e.response?.data || e.response?.status || e.message);
    }
  }
});
app.listen(3000, () => console.log('Klarpakke cron 3000'));
APP
npm i express axios node-cron
export BUBBLE_API_KEY="your_real_key"
pm2 restart bubble-cron --update-env || pm2 start app.js --name bubble-cron
pm2 save
echo "Local OK. Logs:"
pm2 logs bubble-cron --lines 10
curl localhost:3000/health
echo "2. Git save"
git add app.js package.json
git commit -m "Cron v5 full err log" || git init && git add . && git commit -m "Init"
git push origin main || echo "Push manual"
echo "3. VM deploy"
ssh opc@VM 'cat > ~/full-cron.sh <<VMEOF
#!/bin/bash
export BUBBLE_API_KEY="your_real_key"
cd ~/klarpakke || git clone https://github.com/tombomann/klarpakke.git ~/klarpakke && cd ~/klarpakke
git pull
npm i
pm2 restart bubble-cron || (pm2 start app.js --name bubble-cron && pm2 save)
pm2 logs bubble-cron
VMEOF
chmod +x ~/full-cron.sh && ~/full-cron.sh'
echo "Run: Bubble fields + ./full-setup.sh"
