const puppeteer = require('puppeteer');
(async () => {
  const browser = await puppeteer.launch({headless: false, slowMo: 800});
  const page = await browser.newPage();
  await page.setViewport({width: 1920, height: 1080});
  await page.goto('https://bubble.io/builder/klarpakke-trading/version-test');
  console.log('🚀 MANUAL: Login Bubble, then press ENTER here (node console)');
  await new Promise(r => process.stdin.once('data', r));
  
  try {
    // Task 1: Data Types
    console.log('📊 Task1: Data tab');
    await page.waitForSelector('nav a[href*="#datatypespage"], [data-testid*="data"]', {timeout: 10000});
    await page.click('nav a[href*="#datatypespage"], [data-testid*="data"]');
    await page.waitForSelector('[data-testid="data-type-create-button"], button:has-text("New type")', {timeout: 5000});
    await page.click('[data-testid="data-type-create-button"], button:has-text("New type")');
    await page.type('input[placeholder*="Name"], input[aria-label*="name"]', 'Signal');
    await page.click('button[type="submit"], button:has-text("Create")');
    console.log('✅ Data "Signal" created');
    
    // Task 2: Add fields (flex: run multiple)
    console.log('🔧 Task2: Add fields (symbol text, price number etc) - inspect selectors');
    await page.waitForSelector('[data-testid*="field-add"], button:has-text("Add field")', {timeout: 5000});
    // Repeat for fields: await page.click... type...
    
    // Task 3: API Connector
    console.log('🔌 Task3: Plugins > API Connector');
    await page.goto('#pluginspage');
    await page.waitForSelector('text="API Connector", [data-testid*="plugin-search"]', {timeout: 10000});
    await page.type('[data-testid*="plugin-search"]', 'API Connector');
    await page.click('text="API Connector"');
    await page.click('button:has-text("Add a new API")');
    await page.type('input[placeholder*="Name"]', 'Post Signal');
    console.log('🛑 MANUAL: Configure POST URL/key/body, test. Close browser.');
    
  } catch (e) {
    console.error('❌ Error:', e.message);
  }
  await new Promise(r => setTimeout(r, 30000)); // Pause
  await browser.close();
})();
