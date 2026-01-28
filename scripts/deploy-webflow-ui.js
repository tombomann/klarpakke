const { chromium } = require('playwright');
const fs = require('fs');

async function deployToWebflow() {
  console.log('🚀 Starting Webflow deployment...');
  
  const browser = await chromium.launch({ 
    headless: false,  // Vis browser for debugging
    args: ['--no-sandbox', '--disable-setuid-sandbox'],
    slowMo: 100  // Slow down for stability
  });
  
  const context = await browser.newContext({
    viewport: { width: 1920, height: 1080 },
    userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
  });
  
  const page = await context.newPage();

  try {
    const loaderCode = fs.readFileSync('web/dist/webflow-loader.js', 'utf8');
    
    // Sjekk om vi har session cookie (ANBEFALT!)
    if (process.env.WEBFLOW_SESSION_COOKIE && process.env.WEBFLOW_SESSION_COOKIE !== 'REAL_COOKIE_VALUE_HER') {
      console.log('🍪 Using session cookie...');
      
      await context.addCookies([{
        name: 'wf_sid',
        value: process.env.WEBFLOW_SESSION_COOKIE,
        domain: '.webflow.com',
        path: '/',
        httpOnly: true,
        secure: true,
        sameSite: 'Lax'
      }]);
      
      // Gå direkte til Custom Code settings
      console.log('📝 Opening Custom Code page...');
      await page.goto(`https://webflow.com/dashboard/sites/${process.env.WEBFLOW_SITE_ID}/settings/custom-code`, {
        waitUntil: 'domcontentloaded',
        timeout: 30000
      });
      
      // Vent på at siden er klar
      await page.waitForSelector('.CodeMirror, [class*="editor"]', { timeout: 15000 });
      
    } else {
      console.log('⚠️  No valid session cookie found!');
      console.log('Please set WEBFLOW_SESSION_COOKIE:');
      console.log('1. Open https://webflow.com in browser and log in');
      console.log('2. DevTools → Application → Cookies → webflow.com');
      console.log('3. Copy "wf_sid" value');
      console.log('4. Run: echo "COOKIE_VALUE" | gh secret set WEBFLOW_SESSION_COOKIE');
      throw new Error('WEBFLOW_SESSION_COOKIE required');
    }

    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'custom-code-page.png', fullPage: true });
    console.log('📸 Screenshot saved: custom-code-page.png');

    console.log('📤 Injecting footer code into CodeMirror...');

    // Inject code
    const injected = await page.evaluate((code) => {
      const allEditors = Array.from(document.querySelectorAll('.CodeMirror'));
      console.log(`Found ${allEditors.length} CodeMirror editors`);
      
      // Prøv å finne Footer editor
      let footerEditor = allEditors.find(el => {
        const parent = el.closest('[class*="footer"], [data-automation-id*="footer"], [class*="Footer"]');
        if (parent) return true;
        
        // Sjekk heading/label nearby
        const heading = el.closest('section, div')?.querySelector('h1, h2, h3, h4, label');
        return heading?.textContent?.toLowerCase().includes('footer');
      });
      
      // Fallback: bruk siste editor
      if (!footerEditor && allEditors.length > 0) {
        console.log('Using last editor as fallback (usually Footer)');
        footerEditor = allEditors[allEditors.length - 1];
      }

      if (footerEditor?.CodeMirror) {
        const cm = footerEditor.CodeMirror;
        cm.setValue(code);
        cm.refresh();
        
        // Trigger change event
        cm.trigger('change');
        
        console.log('✅ Code injected successfully');
        console.log(`Code length: ${code.length} chars`);
        return true;
      }
      
      console.error('❌ No CodeMirror instance found');
      return false;
    }, loaderCode);

    if (!injected) {
      await page.screenshot({ path: 'inject-failed.png', fullPage: true });
      throw new Error('Failed to inject code into CodeMirror');
    }

    console.log('✅ Code injected!');
    await page.waitForTimeout(2000);

    // Klikk Save
    console.log('💾 Saving...');
    const saveButton = page.locator('button:has-text("Save"), button[type="submit"]').first();
    await saveButton.click({ timeout: 10000 });
    await page.waitForTimeout(5000);
    console.log('✅ Saved!');

    // Gå til site dashboard for å publisere
    console.log('🚀 Publishing site...');
    await page.goto(`https://webflow.com/dashboard/sites/${process.env.WEBFLOW_SITE_ID}`, {
      waitUntil: 'domcontentloaded',
      timeout: 30000
    });
    await page.waitForTimeout(3000);

    const publishButton = page.locator('button:has-text("Publish")').first();
    await publishButton.click({ timeout: 10000 });
    await page.waitForTimeout(4000);

    // Håndter publish dialog
    const confirmButton = page.locator('button:has-text("Publish to selected"), button:has-text("Publish site")').first();
    const dialogVisible = await confirmButton.isVisible({ timeout: 5000 }).catch(() => false);
    
    if (dialogVisible) {
      await confirmButton.click();
      await page.waitForTimeout(6000);
    }

    console.log('✅ Site published successfully!');
    console.log('🎉 Deployment complete!');
    console.log('🌐 Visit: https://www.klarpakke.no');

  } catch (error) {
    console.error('❌ Deployment failed:', error.message);
    await page.screenshot({ path: 'webflow-error.png', fullPage: true });
    console.error('📸 Error screenshot saved: webflow-error.png');
    throw error;
  } finally {
    await browser.close();
  }
}

deployToWebflow().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
