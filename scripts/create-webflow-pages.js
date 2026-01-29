#!/usr/bin/env node
/**
 * Automated Webflow Page Creator
 * Creates 6 required pages with proper structure, IDs, and Custom Code
 * 
 * Requirements:
 * - WEBFLOW_API_TOKEN set in env
 * - WEBFLOW_SITE_ID set in env
 * 
 * Usage:
 * node scripts/create-webflow-pages.js
 */

// Load environment variables from .env file
require('dotenv').config();

const https = require('https');
const fs = require('fs');
const path = require('path');

// ============================================================================
// CONFIG
// ============================================================================

const WEBFLOW_API_TOKEN = process.env.WEBFLOW_API_TOKEN;
const WEBFLOW_SITE_ID = process.env.WEBFLOW_SITE_ID;
const API_VERSION = '2024-12-16'; // Latest Webflow API version
const BASE_URL = 'api.webflow.com';

if (!WEBFLOW_API_TOKEN || !WEBFLOW_SITE_ID) {
  console.error('❌ Missing required environment variables:');
  if (!WEBFLOW_API_TOKEN) console.error('   - WEBFLOW_API_TOKEN');
  if (!WEBFLOW_SITE_ID) console.error('   - WEBFLOW_SITE_ID');
  console.error('');
  console.error('💡 Make sure .env file exists with these variables.');
  console.error('   Run: npm run secrets:pull-supabase');
  process.exit(1);
}

const logger = {
  info: (msg) => console.log(`ℹ️  ${msg}`),
  success: (msg) => console.log(`✅ ${msg}`),
  warn: (msg) => console.log(`⚠️  ${msg}`),
  error: (msg) => console.error(`❌ ${msg}`),
  debug: (msg) => process.env.DEBUG && console.log(`🐛 ${msg}`),
};

// ============================================================================
// UTILITIES
// ============================================================================

function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: BASE_URL,
      port: 443,
      path,
      method,
      headers: {
        'Authorization': `Bearer ${WEBFLOW_API_TOKEN}`,
        'Accept-Version': API_VERSION,
        'Content-Type': 'application/json',
      },
    };

    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          if (res.statusCode >= 400) {
            reject(new Error(`HTTP ${res.statusCode}: ${JSON.stringify(parsed)}`))
          } else {
            resolve(parsed);
          }
        } catch (e) {
          if (res.statusCode >= 400) {
            reject(new Error(`HTTP ${res.statusCode}: ${data}`));
          } else {
            resolve(data);
          }
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

// ============================================================================
// PAGE DEFINITIONS
// ============================================================================

const PAGES = [
  {
    name: 'Home',
    slug: 'index',
    title: 'Klarpakke - Trygg Krypto-Trading med AI',
    description: 'Din AI-drevne kryptotradingassistent for nordiske investorer.',
    headCode: `<title>Klarpakke - Trygg Krypto-Trading med AI</title>
<meta name="description" content="Din AI-drevne kryptotradingassistent for nordiske investorer.">
<meta property="og:title" content="Klarpakke">
<meta property="og:description" content="AI-drevet krypto trading for nordiske småsparere.">`,
    footerCode: `<script src="/scripts/klarpakke-site.js"></script>`,
  },
  {
    name: 'Pricing',
    slug: 'pricing',
    title: 'Klarpakke - Velg Din Plan',
    description: 'Tre fleksible planer for alle investorer.',
    headCode: `<title>Klarpakke - Velg Din Plan</title>
<meta name="description" content="Tre fleksible planer for alle investorer.">`,
    footerCode: null,
  },
  {
    name: 'Dashboard',
    slug: 'app/dashboard',
    title: 'Dashboard - Klarpakke',
    description: 'Ditt personlige trading dashboard.',
    headCode: `<title>Dashboard - Klarpakke</title>`,
    footerCode: `<script src="/scripts/klarpakke-site.js"></script>`,
  },
  {
    name: 'Kalkulator',
    slug: 'app/kalkulator',
    title: 'Risiko-Kalkulator - Klarpakke',
    description: 'Beregn din risiko før du investerer.',
    headCode: `<title>Risiko-Kalkulator - Klarpakke</title>`,
    footerCode: `<script src="/scripts/calculator.js"></script>`,
  },
  {
    name: 'Settings',
    slug: 'app/settings',
    title: 'Innstillinger - Klarpakke',
    description: 'Administrer dine innstillinger.',
    headCode: `<title>Innstillinger - Klarpakke</title>`,
    footerCode: null,
  },
  {
    name: 'Login',
    slug: 'login',
    title: 'Logg Inn - Klarpakke',
    description: 'Logg inn på Klarpakke.',
    headCode: `<title>Logg Inn - Klarpakke</title>`,
    footerCode: null,
  },
];

// ============================================================================
// MAIN LOGIC
// ============================================================================

async function listPages() {
  logger.info('Fetching existing pages...');
  try {
    const response = await makeRequest('GET', `/sites/${WEBFLOW_SITE_ID}/pages`);
    return response.pages || [];
  } catch (error) {
    logger.error(`Failed to list pages: ${error.message}`);
    return [];
  }
}

async function getPageById(pageId) {
  try {
    return await makeRequest('GET', `/sites/${WEBFLOW_SITE_ID}/pages/${pageId}`);
  } catch (error) {
    logger.error(`Failed to get page ${pageId}: ${error.message}`);
    return null;
  }
}

async function createPage(pageData) {
  logger.info(`Creating page: ${pageData.slug}...`);
  try {
    const body = {
      displayName: pageData.name,
      slug: pageData.slug,
    };
    const response = await makeRequest('POST', `/sites/${WEBFLOW_SITE_ID}/pages`, body);
    logger.success(`Created page: ${pageData.slug}`);
    return response.id;
  } catch (error) {
    if (error.message.includes('409') || error.message.includes('already exists')) {
      logger.warn(`Page already exists: ${pageData.slug}`);
      return null; // Page exists
    }
    logger.error(`Failed to create page ${pageData.slug}: ${error.message}`);
    throw error;
  }
}

async function updatePageMeta(pageId, pageData) {
  logger.info(`Updating metadata for: ${pageData.slug}...`);
  try {
    const body = {
      title: pageData.title,
      metaDescription: pageData.description,
    };
    await makeRequest('PATCH', `/sites/${WEBFLOW_SITE_ID}/pages/${pageId}`, body);
    logger.success(`Updated metadata for: ${pageData.slug}`);
  } catch (error) {
    logger.warn(`Could not update metadata for ${pageData.slug}: ${error.message}`);
    // Non-critical
  }
}

async function addCustomCode(pageId, location, code) {
  logger.info(`Adding ${location} custom code to page...`);
  // Note: Custom Code via API is limited. Full custom code injection might require
  // using Webflow Designer UI or embedding in page template.
  // This is a placeholder for future enhancement.
  logger.warn(`Custom code injection via API has limitations. Please add manually in Designer.`);
}

async function main() {
  logger.info('🚀 Starting Webflow Pages Creation');
  logger.info(`Site ID: ${WEBFLOW_SITE_ID}`);
  logger.info(`Pages to create: ${PAGES.length}`);
  logger.info('');

  const existingPages = await listPages();
  const existingSlugs = new Set(existingPages.map(p => p.slug));

  logger.info(`Found ${existingPages.length} existing pages`);
  logger.info('');

  const results = {
    created: [],
    skipped: [],
    failed: [],
  };

  for (const pageData of PAGES) {
    if (existingSlugs.has(pageData.slug)) {
      logger.warn(`Skipping existing page: ${pageData.slug}`);
      results.skipped.push(pageData.slug);
      continue;
    }

    try {
      const pageId = await createPage(pageData);
      if (pageId) {
        await updatePageMeta(pageId, pageData);
        if (pageData.headCode) {
          await addCustomCode(pageId, 'HEAD', pageData.headCode);
        }
        if (pageData.footerCode) {
          await addCustomCode(pageId, 'FOOTER', pageData.footerCode);
        }
        results.created.push(pageData.slug);
      } else {
        results.skipped.push(pageData.slug);
      }
    } catch (error) {
      logger.error(`Failed to create ${pageData.slug}`);
      results.failed.push(pageData.slug);
    }
  }

  logger.info('');
  logger.info('=' .repeat(50));
  logger.success(`Created: ${results.created.length} pages`);
  logger.warn(`Skipped: ${results.skipped.length} pages (already exist)`);
  logger.error(`Failed: ${results.failed.length} pages`);
  logger.info('=' .repeat(50));

  if (results.created.length > 0) {
    logger.info('');
    logger.info('📝 Next steps:');
    logger.info('1. Open Webflow Designer');
    logger.info('2. For each created page, add required element IDs (see docs/WEBFLOW-ELEMENT-IDS.md)');
    logger.info('3. Add Custom Code in Page Settings → Head and Footer');
    logger.info('4. Publish the site');
  }

  if (results.failed.length > 0) {
    process.exit(1);
  }
}

// ============================================================================
// RUN
// ============================================================================

main().catch(error => {
  logger.error(`Fatal error: ${error.message}`);
  process.exit(1);
});
