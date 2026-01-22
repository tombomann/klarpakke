#!/bin/bash
set -e
chmod +x "$0"  # Self-fix
echo "=== KLARPAKKE FULL SETUP v6 ==="
read -p "BUBBLE_API_KEY? " KEY || KEY="your_key"
export BUBBLE_API_KEY="$KEY"
echo "1. App.js debug"
cat > app.js << 'APP'
const express = require('express'); const cron = require('node-cron'); const axios = require('axios'); const app = express();
app.get('/health', (r, res) => res.json({status:'OK'}));
cron.schedule('*/2 * * * *', async () => {
  const data = {symbol:'BTC', price:90000, rsi:38, signal:'HOLD', conf:85, ts:new Date().toISOString()};
  try {
    const res = await axios.post('https://klarpakke-trading.bubbleapps.io/version-test/api/1.1/obj/Signal', data, {
      headers: {'Authorization': `Bearer ${process.env.BUBBLE_API_KEY}`}
    });
    console.log('POST OK:', res.status, data);
  } catch (e) {
    console.log('ERR:', e.response?.status, e.response?.data?.message || e.message);
  }
});
app.listen(3000, () => console.log('Live 3000'));
APP
npm i --silent
pm2 restart bubble-cron --update-env || pm2 start app.js --name bubble-cron && pm2 save autostart
sleep 5
pm2 logs bubble-cron --lines 15
curl localhost:3000/health
echo "2. Git (auth if needed)"
git add app.js package.json .gitignore || git init
echo "app.js\nnode_modules/" > .gitignore
git add .gitignore
git commit -m "v6 cron debug" || git commit -am "v6"
git remote add origin https://github.com/tombomann/klarpakke.git 2>/dev/null || true
git push -u origin main || echo "Push: gh auth login"
echo "3. VM clean deploy"
ssh opc@VM "rm -rf ~/klarpakke ~/bubble-cron.sh; cat > ~/full-vm.sh <<'VM'
#!/bin/bash
export BUBBLE_API_KEY='$KEY'
git clone https://github.com/tombomann/klarpakke.git ~/klarpakke && cd ~/klarpakke
npm i
pm2 start app.js --name bubble-cron --update-env
pm2 save
pm2 logs bubble-cron
VM
chmod +x ~/full-vm.sh && ~/full-vm.sh"
echo "=== DONE: Bubble fields NOW! Check logs for 200/err. ==="
