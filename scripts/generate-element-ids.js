#!/usr/bin/env node
/**
 * Generate Element IDs for Webflow Pages
 * 
 * Generates semantic, Webflow-compliant element IDs
 * Outputs to docs/WEBFLOW-ELEMENT-IDS.md
 * 
 * Usage: npm run ai:generate-ids
 */

const fs = require('fs');
const path = require('path');
const AIContentGenerator = require('../lib/ai-content-generator');

// Page structures
const PAGE_STRUCTURES = {
  landing: {
    sections: [
      { name: 'hero', elements: ['headline', 'subheadline', 'cta-button'] },
      { name: 'features', elements: ['list', 'item-template'] },
      { name: 'testimonials', elements: ['wrapper', 'quote'] },
      { name: 'cta', elements: ['button-primary'] }
    ]
  },
  
  dashboard: {
    sections: [
      { name: 'signals', elements: ['container', 'item-template', 'loading', 'error'] },
      { name: 'filter', elements: ['buy', 'sell', 'all'] }
    ]
  },
  
  calculator: {
    sections: [
      { name: 'calc', elements: ['start', 'crypto-percent', 'plan', 'result-table'] },
      { name: 'risk', elements: ['input-amount', 'input-leverage', 'calculate-btn'] }
    ]
  }
};

async function main() {
  console.log('\n🎯 ELEMENT ID GENERATOR\n');

  const ai = new AIContentGenerator();
  const allIds = {};

  for (const [pageName, structure] of Object.entries(PAGE_STRUCTURES)) {
    console.log(`📄 Generating IDs for: ${pageName}`);
    const ids = await ai.generateElementIDs(structure);
    allIds[pageName] = ids;
  }

  // Generate markdown
  let markdown = '# Webflow Element IDs\n\n';
  markdown += 'Auto-generated element IDs for JavaScript integration.\n\n';
  
  for (const [pageName, ids] of Object.entries(allIds)) {
    markdown += `## ${pageName.charAt(0).toUpperCase() + pageName.slice(1)}\n\n`;
    markdown += '```html\n';
    for (const [key, id] of Object.entries(ids)) {
      markdown += `${id}\n`;
    }
    markdown += '```\n\n';
  }

  // Write to file
  const docsPath = path.join(__dirname, '..', 'docs', 'WEBFLOW-ELEMENT-IDS.md');
  fs.writeFileSync(docsPath, markdown);
  
  console.log(`\n✅ Generated: docs/WEBFLOW-ELEMENT-IDS.md\n`);
}

main().catch(console.error);
