#!/usr/bin/env node
/**
 * SEO Optimize Pages
 * 
 * Optimizes existing Webflow pages for SEO using AI
 * 
 * Usage: npm run ai:seo-optimize
 */

require('dotenv').config();
const WebflowMCP = require('../lib/webflow-mcp');
const AIContentGenerator = require('../lib/ai-content-generator');

const KEYWORDS = {
  landing: ['krypto trading', 'norge', 'ai trading', 'sikkert', 'småsparere'],
  pricing: ['priser', 'planer', 'abonnement', 'gratis', 'premium'],
  dashboard: ['dashboard', 'trading signaler', 'oversikt'],
  calculator: ['kalkulator', 'risiko', 'posisjon', 'sizing']
};

async function main() {
  console.log('\n🔍 SEO OPTIMIZER\n');

  // Validate
  if (!process.env.WEBFLOW_API_TOKEN || !process.env.WEBFLOW_SITE_ID) {
    console.error('❌ Missing Webflow credentials');
    process.exit(1);
  }

  const webflow = new WebflowMCP(
    process.env.WEBFLOW_API_TOKEN,
    process.env.WEBFLOW_SITE_ID
  );
  
  const ai = new AIContentGenerator(process.env.PPLX_API_KEY);

  // Get all pages
  console.log('📚 Fetching pages...');
  const result = await webflow.listPages();
  
  if (!result.success) {
    console.error('❌ Failed:', result.error);
    process.exit(1);
  }

  console.log(`✅ Found ${result.count} pages\n`);

  let optimized = 0;

  // Optimize each page
  for (const page of result.pages) {
    console.log(`🔍 Optimizing: ${page.name}`);

    // Determine page type from slug
    const pageType = page.slug.includes('pricing') ? 'pricing' :
                     page.slug.includes('dashboard') ? 'dashboard' :
                     page.slug.includes('kalkulator') ? 'calculator' :
                     'landing';

    const keywords = KEYWORDS[pageType] || [];

    // Generate SEO metadata
    const content = { headline: page.title || page.name };
    const seo = await ai.optimizeForSEO(content, keywords);

    console.log(`   Title: ${seo.title}`);
    console.log(`   Description: ${seo.description.slice(0, 60)}...`);

    // Update page
    const updateResult = await webflow.updatePageMetadata(page.id, {
      seo: {
        title: seo.title,
        description: seo.description
      }
    });

    if (updateResult.success) {
      console.log('   ✅ Updated\n');
      optimized++;
    } else {
      console.log('   ❌ Failed\n');
    }
  }

  console.log(`\n🎉 Optimized ${optimized}/${result.count} pages\n`);
}

main().catch(console.error);
