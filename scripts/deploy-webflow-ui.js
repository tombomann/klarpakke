const { chromium } = require('playwright');

async function deployToWebflow() {
  const browser = await chromium.launch({ headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    console.log('🔐 Logging in to Webflow...');
    
    // Login med email/password
    await page.goto('https://webflow.com/dashboard/login');
    await page.fill('input[name="email"]', process.env.WEBFLOW_EMAIL);
    await page.fill('input[name="password"]', process.env.WEBFLOW_PASSWORD);
    await page.click('button[type="submit"]');
    await page.waitForURL('**/dashboard/**', { timeout: 10000 });

    console.log('✅ Logged in!');
    console.log('📝 Opening Custom Code settings...');

    // Gå til Custom Code settings
    await page.goto(`https://webflow.com/dashboard/sites/${process.env.WEBFLOW_SITE_ID}/settings/custom-code`);
    await page.waitForLoadState('networkidle');

    // Finn Footer Code editor (CodeMirror)
    console.log('📤 Updating footer code...');
    
    // Klikk på Footer-fanen hvis den finnes
    const footerTab = page.locator('text=Footer Code').or(page.locator('text=Footer')).first();
    if (await footerTab.isVisible()) {
      await footerTab.click();
      await page.waitForTimeout(1000);
    }

    // Webflow bruker CodeMirror - vi må manipulere det direkte
    const loaderCode = process.env.WEBFLOW_LOADER_CODE;
    
    await page.evaluate((code) => {
      // Finn CodeMirror instance for footer
      const editors = document.querySelectorAll('.CodeMirror');
      const footerEditor = Array.from(editors).find(el => {
        const label = el.closest('[data-testid]')?.previousElementSibling?.textContent;
        return label?.includes('Footer') || label?.includes('footer');
      });
      
      if (footerEditor?.CodeMirror) {
        footerEditor.CodeMirror.setValue(code);
        console.log('✅ Code updated in editor');
      } else {
        throw new Error('Could not find footer code editor');
      }
    }, loaderCode);

    await page.waitForTimeout(2000);

    // Klikk Save
    console.log('💾 Saving changes...');
    const saveButton = page.locator('button:has-text("Save")').or(page.locator('[data-testid="save-button"]')).first();
    await saveButton.click();
    await page.waitForTimeout(3000);

    // Publiser site
    console.log('🚀 Publishing site...');
    await page.goto(`https://webflow.com/dashboard/sites/${process.env.WEBFLOW_SITE_ID}`);
    const publishButton = page.locator('button:has-text("Publish")').first();
    await publishButton.click();
    
    // Velg "Publish to selected domains" hvis dialog vises
    const publishDialog = page.locator('button:has-text("Publish to selected")').first();
    if (await publishDialog.isVisible({ timeout: 3000 })) {
      await publishDialog.click();
    }

    await page.waitForTimeout(5000);
    
    console.log('✅ Site published!');
    console.log('🎉 Deployment complete!');

  } catch (error) {
    console.error('❌ Error:', error.message);
    await page.screenshot({ path: 'error.png' });
    throw error;
  } finally {
    await browser.close();
  }
}

deployToWebflow();
