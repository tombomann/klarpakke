#!/usr/bin/env node
/**
 * AI-Powered Webflow Page Builder
 * Automatically creates and populates Webflow pages using AI
 */

require('dotenv').config();
const WebflowMCP = require('../lib/webflow-mcp');
const AIContentGenerator = require('../lib/ai-content-generator');

const WEBFLOW_API_TOKEN = process.env.WEBFLOW_API_TOKEN;
const WEBFLOW_SITE_ID = process.env.WEBFLOW_SITE_ID;
const PPLX_API_KEY = process.env.PPLX_API_KEY;

if (!WEBFLOW_API_TOKEN || !WEBFLOW_SITE_ID) {
  console.error('❌ Missing Webflow credentials');
  process.exit(1);
}

if (!PPLX_API_KEY) {
  console.warn('⚠️  PPLX_API_KEY not set, using fallback content');
}

const webflow = new WebflowMCP(WEBFLOW_API_TOKEN, WEBFLOW_SITE_ID);
const ai = new AIContentGenerator(PPLX_API_KEY);

/**
 * Page templates with requirements
 */
const PAGE_TEMPLATES = {
  landing: {
    slug: 'index',
    name: 'Home',
    title: 'Klarpakke - Trygg Krypto-Trading',
    requirements: {
      tone: 'professional yet friendly',
      targetAudience: 'Norwegian retail investors',
      keyMessage: 'Safe crypto trading with AI',
      sections: ['hero', 'features', 'testimonials', 'cta']
    }
  },
  pricing: {
    slug: 'pricing',
    name: 'Pricing',
    title: 'Klarpakke - Priser',
    requirements: {
      plans: ['Paper (Free)', 'Safe (399 kr)', 'Pro (799 kr)', 'Extrem (1999 kr)'],
      emphasis: 'value and transparency'
    }
  },
  dashboard: {
    slug: 'app/dashboard',
    name: 'Dashboard',
    title: 'Klarpakke - Dashboard',
    requirements: {
      type: 'app',
      features: ['signals list', 'filters', 'real-time updates']
    }
  },
  calculator: {
    slug: 'app/kalkulator',
    name: 'Kalkulator',
    title: 'Klarpakke - Risk Kalkulator',
    requirements: {
      type: 'app',
      features: ['risk calculator', 'position sizing', 'P&L simulator']
    }
  }
};

/**
 * Build all pages
 */
async function buildAllPages() {
  console.log('🤖 AI-POWERED WEBFLOW PAGE BUILDER');
  console.log('════════════════════════════════════════');
  console.log('');

  // Get existing pages
  console.log('📚 Checking existing pages...');
  const existingPages = await webflow.listPages();
  
  if (!existingPages.success) {
    console.error('❌ Failed to list pages:', existingPages.error);
    return;
  }

  console.log(`✅ Found ${existingPages.count} existing pages`);
  console.log('');

  // Build each page
  let created = 0;
  let skipped = 0;
  let failed = 0;

  for (const [pageType, template] of Object.entries(PAGE_TEMPLATES)) {
    console.log(`🎨 Building: ${template.name} (${template.slug})`);

    // Check if exists
    const exists = existingPages.pages.some(p => p.slug === template.slug);
    if (exists) {
      console.log(`   ⏭️  Skip: Already exists`);
      skipped++;
      continue;
    }

    try {
      // Generate content with AI
      console.log(`   🤖 Generating content with AI...`);
      const content = await ai.generatePageContent(pageType, template.requirements);
      
      // Create page
      console.log(`   📝 Creating page...`);
      const result = await webflow.createPage({
        slug: template.slug,
        name: template.name,
        title: template.title
      });

      if (!result.success) {
        console.log(`   ❌ Failed: ${result.error}`);
        failed++;
        continue;
      }

      console.log(`   ✅ Created: ${result.pageId}`);
      console.log(`   💬 Content: ${content.headline || 'Generated'}`);
      created++;

      // Rate limiting
      await sleep(1000);

    } catch (error) {
      console.log(`   ❌ Error: ${error.message}`);
      failed++;
    }

    console.log('');
  }

  console.log('════════════════════════════════════════');
  console.log('🎉 BUILD COMPLETE!');
  console.log(`   Created: ${created}`);
  console.log(`   Skipped: ${skipped}`);
  console.log(`   Failed: ${failed}`);
  console.log('════════════════════════════════════════');
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Run
buildAllPages().catch(error => {
  console.error('❌ Fatal error:', error);
  process.exit(1);
});
