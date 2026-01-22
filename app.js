const express = require('express');
const cron = require('node-cron');
const axios = require('axios');
const app = express();
app.use(express.json());
app.get('/health', (req, res) => res.json({ok: true}));
cron.schedule('*/5 * * * *', async () => {
  const data = {
    symbol: 'BTC',
    rsi: 38.5,
    signal: 'HOLD',
    confidence: 85,
    risk_pct: 0.5,
    timestamp: new Date().toISOString()
  };
  try {
    await axios.post(process.env.BUBBLE_URL || 'https://tom-58107.bubbleapps.io/version-test/api/1.1/obj/Signal', data, {
      headers: { 'Authorization': `Bearer ${process.env.BUBBLE_API_KEY}` }
    });
    console.log('Posted:', data);
  } catch (e) { console.log('Err:', e.response?.status, e.message); }
});
app.listen(3000, () => console.log('Live 3000'));
