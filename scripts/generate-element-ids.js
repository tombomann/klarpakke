#!/usr/bin/env node
/**
 * Generate Element IDs using AI
 */

require('dotenv').config();
const WebflowMCP = require('../lib/webflow-mcp');
const AIContentGenerator = require('../lib/ai-content-generator');

const WEBFLOW_API_TOKEN = process.env.WEBFLOW_API_TOKEN;
const WEBFLOW_SITE_ID = process.env.WEBFLOW_SITE_ID;
const PPLX_API_KEY = process.env.PPLX_API_KEY;

const webflow = new WebflowMCP(WEBFLOW_API_TOKEN, WEBFLOW_SITE_ID);
const ai = new AIContentGenerator(PPLX_API_KEY);

/**
 * Page structures for ID generation
 */
const PAGE_STRUCTURES = {
  dashboard: {
    sections: ['signals-container', 'filter-buttons', 'signal-item-template'],
    components: ['loading-spinner', 'error-message']
  },
  calculator: {
    inputs: ['risk-input-amount', 'risk-input-leverage'],
    buttons: ['risk-calculate-btn'],
    outputs: ['risk-result-container', 'risk-pnl-display']
  },
  settings: {
    forms: ['settings-form'],
    displays: ['user-email-display'],
    buttons: ['logout-button', 'theme-toggle']
  }
};

async function generateElementIDs() {
  console.log('🎯 Generating Element IDs with AI...');
  console.log('');

  for (const [page, structure] of Object.entries(PAGE_STRUCTURES)) {
    console.log(`📝 ${page}:`);
    
    if (PPLX_API_KEY) {
      const ids = await ai.generateElementIDs(structure);
      ids.forEach(item => {
        console.log(`   - ${item.element}: #${item.id}`);
      });
    } else {
      // Fallback: Use structure as-is
      Object.entries(structure).forEach(([category, elements]) => {
        elements.forEach(id => {
          console.log(`   - ${category}: #${id}`);
        });
      });
    }
    
    console.log('');
  }

  console.log('✅ Element IDs generated!');
  console.log('   Copy these to docs/WEBFLOW-ELEMENT-IDS.md');
}

generateElementIDs();
