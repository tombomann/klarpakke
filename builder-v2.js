const puppeteer = require('puppeteer');
async function safeClick(page, selector, timeout = 5000) {
  try {
    await page.waitForSelector(selector, {timeout});
    await page.click(selector);
    console.log('✅ Clicked:', selector);
    return true;
  } catch (e) {
    console.log('⚠️ Skip:', selector, e.message);
    return false;
  }
}
(async () => {
  const browser = await puppeteer.launch({headless: false, slowMo: 1000});
  const page = await browser.newPage();
  await page.goto('https://bubble.io/builder/klarpakke-trading/version-test', {waitUntil: 'networkidle2'});
  console.log('1. LOGIN manual, ENTER');
  await new Promise(r => process.stdin.once('data', r));
  // Data tab
  await safeClick(page, 'nav a[href*="#datatypespage"], [aria-label*="Data"], text="Data"');
  await safeClick(page, '[data-testid="data-type-create-button"], button:text("New type")');
  await page.type('input[placeholder*="name"]', 'Signal', {delay: 100});
  await safeClick(page, 'button[type="submit"]');
  console.log('✅ Signal type');
  // Plugins
  await page.goto('#pluginspage');
  await page.type('input[placeholder*="Search"]', 'API Connector');
  await safeClick(page, 'text="API Connector"');
  await safeClick(page, 'button:text("Add")');
  console.log('🛑 MANUAL config API, inspect selectors for more');
  await new Promise(r => setTimeout(r, 60000));
  await browser.close();
})();
