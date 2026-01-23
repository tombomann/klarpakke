const { chromium } = require('playwright');

async function importScenarios() {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  // Login
  await page.goto('https://eu1.make.com/login');
  await page.fill('#email', process.env.MAKE_EMAIL);
  await page.fill('#password', process.env.MAKE_PASSWORD);
  await page.click('button[type="submit"]');
  
  // Wait for dashboard
  await page.waitForURL('**/scenarios');
  
  // Import each scenario
  const scenarios = [
    'signal-approve.json',
    'signal-reject.json', 
    'kill-switch.json',
    'risk-monitor.json',
    'daily-reset.json'
  ];
  
  for (const scenario of scenarios) {
    await page.click('[data-testid="create-scenario"]');
    await page.click('[data-testid="import-blueprint"]');
    await page.setInputFiles('input[type="file"]', `make/flows/${scenario}`);
    await page.click('[data-testid="save"]');
    console.log(`✅ Imported: ${scenario}`);
  }
  
  await browser.close();
}

importScenarios();
