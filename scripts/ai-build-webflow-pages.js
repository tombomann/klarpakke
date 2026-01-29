#!/usr/bin/env node
/**
 * AI-Powered Webflow Page Builder
 * 
 * Automatically builds Webflow pages using AI-generated content
 * 
 * Usage:
 *   npm run ai:build-pages
 *   npm run ai:build-pages -- landing,pricing
 * 
 * @author Klarpakke Team
 */

require('dotenv').config();
const WebflowMCP = require('../lib/webflow-mcp');
const AIContentGenerator = require('../lib/ai-content-generator');

// Page templates
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

async function main() {
  console.log('\n🤖 AI-POWERED WEBFLOW PAGE BUILDER');
  console.log('========================================\n');

  // Validate environment
  if (!process.env.WEBFLOW_API_TOKEN) {
    console.error('❌ WEBFLOW_API_TOKEN missing in .env');
    process.exit(1);
  }
  
  if (!process.env.WEBFLOW_SITE_ID) {
    console.error('❌ WEBFLOW_SITE_ID missing in .env');
    process.exit(1);
  }

  // Initialize
  const webflow = new WebflowMCP(
    process.env.WEBFLOW_API_TOKEN,
    process.env.WEBFLOW_SITE_ID
  );
  
  const ai = new AIContentGenerator(process.env.PPLX_API_KEY);
  
  if (!process.env.PPLX_API_KEY) {
    console.log('ℹ️  PPLX_API_KEY not set - using fallback content\n');
  }

  // Determine which pages to build
  const args = process.argv.slice(2);
  const pagesArg = args[0] || 'all';
  
  let pagesToBuild;
  if (pagesArg === 'all') {
    pagesToBuild = Object.keys(PAGE_TEMPLATES);
  } else {
    pagesToBuild = pagesArg.split(',').map(p => p.trim());
  }

  console.log(`📄 Building pages: ${pagesToBuild.join(', ')}\n`);

  // Get existing pages
  console.log('📚 Checking existing pages...');
  const existingResult = await webflow.listPages();
  
  if (!existingResult.success) {
    console.error('❌ Failed to list pages:', existingResult.error);
    process.exit(1);
  }
  
  console.log(`✅ Found ${existingResult.count} existing pages\n`);
  const existingSlugs = new Set(existingResult.pages.map(p => p.slug));

  // Build stats
  const stats = {
    created: 0,
    skipped: 0,
    failed: 0
  };

  // Build each page
  for (const pageKey of pagesToBuild) {
    const template = PAGE_TEMPLATES[pageKey];
    
    if (!template) {
      console.warn(`⚠️  Unknown page: ${pageKey}`);
      continue;
    }

    console.log(`🎨 Building: ${template.name} (${template.slug})`);

    // Skip if exists
    if (existingSlugs.has(template.slug)) {
      console.log(`   ⏭️  Skip: Already exists\n`);
      stats.skipped++;
      continue;
    }

    // Generate content with AI
    console.log('   🤖 Generating content with AI...');
    const content = await ai.generatePageContent(pageKey, template.requirements);
    
    // Create page
    console.log('   📝 Creating page...');
    const result = await webflow.createPage({
      slug: template.slug,
      name: template.name,
      title: template.title,
      description: content.subheadline || content.headline || template.title
    });

    if (result.success) {
      console.log(`   ✅ Created: ${result.pageId}`);
      console.log(`   💬 Content: ${content.headline || 'Default content'}\n`);
      stats.created++;
    } else {
      console.error(`   ❌ Failed: ${result.error}\n`);
      stats.failed++;
    }
  }

  // Summary
  console.log('========================================');
  console.log('🎉 BUILD COMPLETE!');
  console.log(`   Created: ${stats.created}`);
  console.log(`   Skipped: ${stats.skipped}`);
  console.log(`   Failed: ${stats.failed}`);
  console.log('========================================\n');

  process.exit(stats.failed > 0 ? 1 : 0);
}

main().catch(error => {
  console.error('\n❌ Fatal error:', error.message);
  console.error(error.stack);
  process.exit(1);
});
