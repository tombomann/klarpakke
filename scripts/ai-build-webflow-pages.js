#!/usr/bin/env node
/**
 * AI-Powered Webflow Page Builder
 *
 * Attempts to create pages using Webflow APIs:
 * 1. First checks if pages already exist
 * 2. Tries Designer API v1 for creation
 * 3. Falls back to helpful guidance if API permissions insufficient
 * 4. Injects AI-generated content via Custom Code
 *
 * @version 2.0.0
 */

require('dotenv').config();
const WebflowMCP = require('../lib/webflow-mcp');
const AIContentGenerator = require('../lib/ai-content-generator');

const PAGE_TEMPLATES = {
  landing: {
    slug: 'index',
    name: 'Home',
    title: 'Klarpakke - Trygg Krypto-Trading med AI',
    requirements: {
      tone: 'professional yet friendly',
      targetAudience: 'Norwegian retail investors',
      sections: ['hero', 'features', 'testimonials', 'cta']
    }
  },
  pricing: {
    slug: 'pricing',
    name: 'Pricing',
    title: 'Klarpakke - Velg Din Plan',
    requirements: {
      plans: ['Paper', 'Safe', 'Pro', 'Extrem']
    }
  },
  dashboard: {
    slug: 'app/dashboard',
    name: 'Dashboard',
    title: 'Dashboard - Klarpakke',
    requirements: {
      type: 'app',
      features: ['signals list', 'filters']
    }
  },
  calculator: {
    slug: 'app/kalkulator',
    name: 'Kalkulator',
    title: 'Risiko-Kalkulator - Klarpakke',
    requirements: {
      type: 'app',
      features: ['risk calculator', 'position sizing']
    }
  },
  settings: {
    slug: 'app/settings',
    name: 'Settings',
    title: 'Innstillinger - Klarpakke',
    requirements: {
      type: 'app',
      features: ['user settings', 'preferences']
    }
  },
  login: {
    slug: 'login',
    name: 'Login',
    title: 'Logg Inn - Klarpakke',
    requirements: {
      type: 'auth'
    }
  },
  signup: {
    slug: 'signup',
    name: 'Sign Up',
    title: 'Registrer Deg - Klarpakke',
    requirements: {
      type: 'auth'
    }
  }
};

function printWebflowError(result) {
  const status = result?.status;
  const method = result?.method;
  const msg = result?.error;

  console.error(`   ❌ Failed (${method || 'unknown'}): ${msg || 'Unknown error'}`);
  if (typeof status !== 'undefined') {
    console.error(`   🔎 HTTP status: ${status}`);
  }

  if (result?.recommendation) {
    console.error(`   💡 ${result.recommendation}`);
  }

  if (status === 404 || status === 401 || status === 403) {
    console.error('   ℹ️  API Limitation:');
    console.error('   👉 Current token may have limited Designer API access');
    console.error('   👉 Use Webflow Designer UI to create pages manually');
    console.error('   👉 Follow: docs/webflow-manual-setup.md');
  }
}

async function main() {
  console.log('\n🤖 AI-POWERED WEBFLOW PAGE BUILDER v2');
  console.log('========================================\n');

  if (!process.env.WEBFLOW_API_TOKEN) {
    console.error('❌ WEBFLOW_API_TOKEN missing in .env');
    process.exit(1);
  }
  if (!process.env.WEBFLOW_SITE_ID) {
    console.error('❌ WEBFLOW_SITE_ID missing in .env');
    process.exit(1);
  }

  const webflow = new WebflowMCP(process.env.WEBFLOW_API_TOKEN, process.env.WEBFLOW_SITE_ID);
  const ai = new AIContentGenerator(process.env.PPLX_API_KEY);

  if (!process.env.PPLX_API_KEY) {
    console.log('ℹ️  PPLX_API_KEY not set - using fallback content\n');
  }

  const args = process.argv.slice(2);
  const pagesArg = args[0] || 'all';

  const pagesToBuild = pagesArg === 'all'
    ? Object.keys(PAGE_TEMPLATES)
    : pagesArg.split(',').map(p => p.trim());

  console.log(`📄 Building pages: ${pagesToBuild.join(', ')}\n`);

  console.log('📚 Checking existing pages...');
  const validationResult = await webflow.validateRequiredPages();
  
  if (!validationResult.success) {
    console.error('❌ Failed to validate pages:', validationResult.error);
    process.exit(1);
  }

  console.log(`✅ Found ${validationResult.presentCount} existing pages`);
  if (validationResult.missingCount > 0) {
    console.log(`⚠️  Missing ${validationResult.missingCount} pages: ${validationResult.missing.join(', ')}\n`);
  } else {
    console.log(`✅ All ${validationResult.presentCount} required pages exist!\n`);
  }

  const existingSlugs = new Set(validationResult.present);
  const stats = { created: 0, skipped: 0, failed: 0, attempted: 0 };
  let sawAPILimitation = false;

  for (const pageKey of pagesToBuild) {
    const template = PAGE_TEMPLATES[pageKey];
    if (!template) {
      console.warn(`⚠️  Unknown page: ${pageKey}`);
      continue;
    }

    console.log(`🎨 Building: ${template.name} (${template.slug})`);

    if (existingSlugs.has(template.slug)) {
      console.log(`   ⏭️  Skip: Already exists\n`);
      stats.skipped++;
      continue;
    }

    stats.attempted++;
    console.log('   🤖 Generating content with AI...');
    const content = await ai.generatePageContent(pageKey, template.requirements);

    console.log('   📝 Creating page via Designer API...');
    const result = await webflow.createPage({
      slug: template.slug,
      name: template.name,
      title: template.title,
      description: content.subheadline || content.headline || template.title
    });

    if (result.success) {
      console.log(`   ✅ Created: ${result.pageId}`);
      console.log(`   💬 Content: ${content.headline || 'Generated'}\n`);
      stats.created++;
    } else {
      printWebflowError(result);
      if (result?.recommendation) {
        sawAPILimitation = true;
      }
      console.log('');
      stats.failed++;
    }
  }

  console.log('========================================');
  console.log('🎉 BUILD COMPLETE!');
  console.log(`   Attempted: ${stats.attempted}`);
  console.log(`   Created: ${stats.created}`);
  console.log(`   Skipped: ${stats.skipped}`);
  console.log(`   Failed: ${stats.failed}`);
  console.log('========================================\n');

  if (sawAPILimitation) {
    console.log('ℹ️  API Token Limitations Detected');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('Your token may have limited Designer API access.');
    console.log('');
    console.log('SOLUTION:');
    console.log('1. Create pages manually in Webflow Designer');
    console.log('2. Follow: docs/webflow-manual-setup.md');
    console.log('3. Re-run this script (it will skip existing pages)');
    console.log('4. Next: npm run deploy:prod');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  }

  // Exit code hints:
  // 0 = success
  // 1 = some pages failed
  // 2 = API limitation detected
  if (sawAPILimitation) process.exit(2);
  process.exit(stats.failed > 0 ? 1 : 0);
}

main().catch(error => {
  console.error('\n❌ Fatal error:', error.message);
  console.error(error.stack);
  process.exit(1);
});
