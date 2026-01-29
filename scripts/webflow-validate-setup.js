#!/usr/bin/env node
/**
 * Webflow Setup Validator
 * Checks that all required collections and settings exist
 */

require('dotenv').config();

const WEBFLOW_API_TOKEN = process.env.WEBFLOW_API_TOKEN;
const WEBFLOW_SITE_ID = process.env.WEBFLOW_SITE_ID;

if (!WEBFLOW_API_TOKEN || !WEBFLOW_SITE_ID) {
  console.error('❌ Missing WEBFLOW_API_TOKEN or WEBFLOW_SITE_ID');
  process.exit(1);
}

const REQUIRED_COLLECTIONS = ['Signals', 'Testimonials', 'FAQ Items'];

async function validateSetup() {
  console.log('🔍 WEBFLOW SETUP VALIDATION');
  console.log('════════════════════════════════════════════════════');
  console.log('');

  let errors = 0;
  let warnings = 0;

  try {
    // 1. Test API connection
    console.log('1️⃣ Testing Webflow API connection...');
    const siteResponse = await fetch(
      `https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}`,
      {
        headers: {
          'Authorization': `Bearer ${WEBFLOW_API_TOKEN}`,
          'accept': 'application/json'
        }
      }
    );

    if (!siteResponse.ok) {
      console.error(`   ❌ API connection failed: HTTP ${siteResponse.status}`);
      errors++;
      process.exit(1);
    }

    const site = await siteResponse.json();
    console.log(`   ✅ Connected to: ${site.displayName || 'Unknown Site'}`);
    console.log('');

    // 2. Check collections
    console.log('2️⃣ Checking CMS collections...');
    const collectionsResponse = await fetch(
      `https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/collections`,
      {
        headers: {
          'Authorization': `Bearer ${WEBFLOW_API_TOKEN}`,
          'accept': 'application/json'
        }
      }
    );

    if (!collectionsResponse.ok) {
      console.error(`   ❌ Failed to fetch collections`);
      errors++;
    } else {
      const { collections } = await collectionsResponse.json();
      console.log(`   Found ${collections.length} collections:`);

      const existingNames = collections.map(c => c.displayName);

      REQUIRED_COLLECTIONS.forEach(required => {
        if (existingNames.includes(required)) {
          console.log(`   ✅ ${required}`);
        } else {
          console.log(`   ⚠️  ${required} (missing)`);
          warnings++;
        }
      });
    }
    console.log('');

    // 3. Check site status
    console.log('3️⃣ Checking site status...');
    console.log(`   Domain: ${site.customDomain || site.previewUrl || 'N/A'}`);
    console.log(`   Published: ${site.lastPublished ? 'Yes' : 'No'}`);
    console.log('');

    // Summary
    console.log('════════════════════════════════════════════════════');
    console.log('📊 VALIDATION SUMMARY');
    console.log('════════════════════════════════════════════════════');
    console.log(`✅ Passed checks: ${3 - errors}`);
    console.log(`⚠️  Warnings: ${warnings}`);
    console.log(`❌ Errors: ${errors}`);
    console.log('');

    if (errors > 0) {
      console.log('❌ VALIDATION FAILED');
      process.exit(1);
    } else if (warnings > 0) {
      console.log('⚠️  VALIDATION PASSED WITH WARNINGS');
      console.log('   Run: npm run webflow:auto-setup to create missing collections');
    } else {
      console.log('✅ ALL CHECKS PASSED!');
    }

  } catch (error) {
    console.error('❌ Validation failed:', error.message);
    process.exit(1);
  }
}

validateSetup();
