/**
 * Webflow Designer Extension: Klarpakke Page Creator
 * 
 * Abilities:
 *  - createPage: Create a new page in the Webflow site
 *  - listPages: List all pages
 *  - updateElement: Update element properties
 * 
 * UI:
 *  1. "Create Klarpakke Pages" button
 *  2. "Verify Element IDs" button
 *  3. Status panel with creation report
 */

import { WebflowAPI } from '@webflow/sdk';

const API = new WebflowAPI();

const PAGES_TO_CREATE = [
  { name: 'Home', slug: 'index', path: '/' },
  { name: 'Pricing', slug: 'pricing', path: '/pricing' },
  { name: 'Dashboard', slug: 'app-dashboard', path: '/app/dashboard' },
  { name: 'Calculator', slug: 'app-kalkulator', path: '/app/kalkulator' },
  { name: 'Settings', slug: 'app-settings', path: '/app/settings' },
  { name: 'Login', slug: 'login', path: '/login' },
  { name: 'Sign Up', slug: 'signup', path: '/signup' },
];

const REQUIRED_IDS = {
  'index': ['nav', 'hero', 'footer'],
  'pricing': ['pricing-table', 'cta-button'],
  'app-dashboard': ['dashboard-content', 'app-sidebar'],
  'app-kalkulator': ['calculator-input', 'calculator-result'],
  'app-settings': ['settings-form', 'save-button'],
  'login': ['login-form', 'email-input', 'password-input'],
  'signup': ['signup-form', 'terms-checkbox'],
};

/**
 * Create all Klarpakke pages (idempotent)
 */
async function createKlarpakkePages() {
  console.log('[Klarpakke] Starting page creation...');
  const results = { created: 0, skipped: 0, errors: 0 };

  for (const pageSpec of PAGES_TO_CREATE) {
    try {
      // Check if page already exists
      const existingPages = await API.listPages();
      const exists = existingPages.some((p) => p.slug === pageSpec.slug);

      if (exists) {
        console.log(`[Klarpakke] Page '${pageSpec.name}' already exists, skipping`);
        results.skipped++;
        continue;
      }

      // Create page
      const newPage = await API.createPage({
        title: pageSpec.name,
        slug: pageSpec.slug,
        userFriendlyPath: pageSpec.path,
      });

      console.log(`[Klarpakke] ✓ Created page: ${pageSpec.name} (${newPage.id})`);
      results.created++;
    } catch (error) {
      console.error(`[Klarpakke] ✗ Failed to create ${pageSpec.name}:`, error.message);
      results.errors++;
    }
  }

  console.log(`[Klarpakke] Creation summary: ${results.created} created, ${results.skipped} skipped, ${results.errors} errors`);
  return results;
}

/**
 * Verify that required element IDs exist on each page
 */
async function verifyElementIds() {
  console.log('[Klarpakke] Verifying required element IDs...');
  const report = {};

  for (const [slug, requiredIds] of Object.entries(REQUIRED_IDS)) {
    try {
      const pages = await API.listPages();
      const page = pages.find((p) => p.slug === slug);

      if (!page) {
        report[slug] = { status: 'missing_page', missingIds: requiredIds };
        continue;
      }

      // Get page elements
      const elements = await API.getPageElements(page.id);
      const elementIds = elements.map((e) => e.customAttributes?.['data-id'] || e.id);
      const missing = requiredIds.filter((id) => !elementIds.includes(id));

      report[slug] = {
        status: missing.length === 0 ? 'ok' : 'missing_ids',
        missingIds: missing,
      };
    } catch (error) {
      report[slug] = { status: 'error', message: error.message };
    }
  }

  console.log('[Klarpakke] Verification report:', JSON.stringify(report, null, 2));
  return report;
}

/**
 * UI: Render buttons and status
 */
function setupUI() {
  const container = document.querySelector('#klarpakke-extension');

  if (!container) {
    console.error('[Klarpakke] Extension container #klarpakke-extension not found');
    return;
  }

  container.innerHTML = `
    <div style="padding: 20px; font-family: sans-serif;">
      <h2>🧨 Klarpakke Page Creator</h2>
      <p>Create and verify pages for your Klarpakke app.</p>
      
      <div style="margin: 20px 0;">
        <button id="create-pages" style="padding: 10px 20px; margin-right: 10px; background: #2196F3; color: white; border: none; border-radius: 4px; cursor: pointer;">
          ✨ Create Klarpakke Pages
        </button>
        <button id="verify-ids" style="padding: 10px 20px; background: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer;">
          ✅ Verify Element IDs
        </button>
      </div>
      
      <div id="status" style="margin-top: 20px; padding: 10px; background: #f0f0f0; border-radius: 4px; display: none;">
        <pre id="status-text" style="white-space: pre-wrap; word-break: break-word;"></pre>
      </div>
    </div>
  `;

  document.querySelector('#create-pages').addEventListener('click', async () => {
    showStatus('Creating pages...');
    try {
      const results = await createKlarpakkePages();
      showStatus(`Success!\n\n${JSON.stringify(results, null, 2)}`);
    } catch (error) {
      showStatus(`Error: ${error.message}`);
    }
  });

  document.querySelector('#verify-ids').addEventListener('click', async () => {
    showStatus('Verifying element IDs...');
    try {
      const report = await verifyElementIds();
      showStatus(`Report:\n\n${JSON.stringify(report, null, 2)}`);
    } catch (error) {
      showStatus(`Error: ${error.message}`);
    }
  });
}

function showStatus(message) {
  const statusDiv = document.querySelector('#status');
  const statusText = document.querySelector('#status-text');
  statusDiv.style.display = 'block';
  statusText.textContent = message;
}

// Initialize on load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', setupUI);
} else {
  setupUI();
}

export { createKlarpakkePages, verifyElementIds };
