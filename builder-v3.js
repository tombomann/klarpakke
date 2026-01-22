const puppeteer = require('puppeteer');
async function safeClick(page, selector, desc) {
  try {
    await page.waitForSelector(selector, {timeout: 8000});
    await page.click(selector);
    console.log(`✅ ${desc}`);
  } catch { console.log(`⚠️ ${desc}`); }
}
(async () => {
  const browser = await puppeteer.launch({headless: false, slowMo: 1000});
  const page = await browser.newPage();
  await page.goto('https://bubble.io/builder/klarpakke-trading/version-test');
  console.log('LOGIN ENTER');
  await new Promise(r => process.stdin.once('data', r));
  // Data tab (sidenav href)
  safeClick(page, 'a[href="/datatypespage"], nav a[href*="#datatypespage"], [data-cy*="data-tab"]', 'Data tab');
  safeClick(page, 'button[data-testid="data-type-create-button"], button:contains("New type")', 'New type');
  await page.type('input[placeholder*="Name your data type"], input[data-testid*="name"]', 'Signal');
  safeClick(page, 'button[type="submit"], .btn-primary', 'Create');
  console.log('✅ Signal created - F12 inspect fields add');
  // Pause inspect
  await new Promise(r => setTimeout(r, 20000));
  await browser.close();
})();
