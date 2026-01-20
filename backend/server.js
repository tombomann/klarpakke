const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ 
    status: 'OK', 
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    env: process.env.NODE_ENV || 'production',
    ip: '79.76.63.189'
  });
});

app.get('/api/status', (req, res) => {
  res.json({ 
    backend: 'klarpakke-vm-v2',
    ai: 'ready',
    node: process.version,
    pm2: true
  });
});

app.listen(PORT, () => {
  console.log(`🚀 Klarpakke LIVE on port ${PORT}`);
});