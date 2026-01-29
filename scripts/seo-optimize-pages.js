#!/usr/bin/env node
/**
 * SEO Optimization using AI
 */

require('dotenv').config();
const AIContentGenerator = require('../lib/ai-content-generator');

const PPLX_API_KEY = process.env.PPLX_API_KEY;

if (!PPLX_API_KEY) {
  console.log('⚠️  PPLX_API_KEY not set, skipping SEO optimization');
  process.exit(0);
}

const ai = new AIContentGenerator(PPLX_API_KEY);

const PAGES = {
  landing: {
    content: 'Klarpakke er en AI-drevet krypto trading plattform for nordmenn.',
    keywords: ['krypto trading', 'AI trading', 'trygg investering', 'norsk']
  },
  pricing: {
    content: 'Våre priser: Paper (gratis), Safe (399 kr), Pro (799 kr), Extrem (1999 kr)',
    keywords: ['krypto priser', 'trading abonnement', 'investering pakker']
  }
};

async function optimizePages() {
  console.log('🔍 SEO Optimization with AI...');
  console.log('');

  for (const [page, data] of Object.entries(PAGES)) {
    console.log(`📝 ${page}:`);
    
    const optimized = await ai.optimizeForSEO(data.content, data.keywords);
    
    console.log(`   Title: ${optimized.title || 'N/A'}`);
    console.log(`   Description: ${optimized.description || 'N/A'}`);
    console.log(`   Headers: ${optimized.headers?.length || 0}`);
    console.log('');
  }

  console.log('✅ SEO optimization complete!');
}

optimizePages();
