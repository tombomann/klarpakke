#!/usr/bin/env node
/**
 * Automatic Webflow CMS Collection Creator
 * Creates all required collections if they don't exist
 */

require('dotenv').config();

const WEBFLOW_API_TOKEN = process.env.WEBFLOW_API_TOKEN;
const WEBFLOW_SITE_ID = process.env.WEBFLOW_SITE_ID;

if (!WEBFLOW_API_TOKEN || !WEBFLOW_SITE_ID) {
  console.error('❌ Missing WEBFLOW_API_TOKEN or WEBFLOW_SITE_ID');
  process.exit(1);
}

// Collection schemas
const COLLECTIONS = {
  signals: {
    displayName: 'Signals',
    singularName: 'Signal',
    fields: [
      { slug: 'name', displayName: 'Name', type: 'PlainText', required: true },
      { slug: 'symbol', displayName: 'Symbol', type: 'PlainText', required: true },
      { slug: 'direction', displayName: 'Direction', type: 'Option', required: true, options: ['BUY', 'SELL'] },
      { slug: 'confidence', displayName: 'Confidence', type: 'Number', required: true },
      { slug: 'reason', displayName: 'Reason', type: 'RichText', required: false },
      { slug: 'status', displayName: 'Status', type: 'Option', required: true, options: ['pending', 'approved', 'rejected'] },
      { slug: 'ai-model', displayName: 'AI Model', type: 'PlainText', required: false },
    ]
  },
  testimonials: {
    displayName: 'Testimonials',
    singularName: 'Testimonial',
    fields: [
      { slug: 'name', displayName: 'Name', type: 'PlainText', required: true },
      { slug: 'quote', displayName: 'Quote', type: 'RichText', required: true },
      { slug: 'role', displayName: 'Role', type: 'PlainText', required: false },
      { slug: 'avatar', displayName: 'Avatar', type: 'ImageRef', required: false },
      { slug: 'rating', displayName: 'Rating', type: 'Number', required: false },
    ]
  },
  faq: {
    displayName: 'FAQ Items',
    singularName: 'FAQ Item',
    fields: [
      { slug: 'question', displayName: 'Question', type: 'PlainText', required: true },
      { slug: 'answer', displayName: 'Answer', type: 'RichText', required: true },
      { slug: 'category', displayName: 'Category', type: 'PlainText', required: false },
      { slug: 'order', displayName: 'Order', type: 'Number', required: false },
    ]
  },
};

async function getExistingCollections() {
  const response = await fetch(
    `https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/collections`,
    {
      headers: {
        'Authorization': `Bearer ${WEBFLOW_API_TOKEN}`,
        'accept': 'application/json'
      }
    }
  );

  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`);
  }

  const data = await response.json();
  return data.collections || [];
}

async function createCollection(schema) {
  console.log(`📦 Creating collection: ${schema.displayName}...`);

  const response = await fetch(
    `https://api.webflow.com/v2/sites/${WEBFLOW_SITE_ID}/collections`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${WEBFLOW_API_TOKEN}`,
        'Content-Type': 'application/json',
        'accept': 'application/json'
      },
      body: JSON.stringify({
        displayName: schema.displayName,
        singularName: schema.singularName,
        fields: schema.fields
      })
    }
  );

  if (!response.ok) {
    const error = await response.text();
    throw new Error(`Failed to create ${schema.displayName}: ${error}`);
  }

  const data = await response.json();
  console.log(`✅ Created: ${schema.displayName} (ID: ${data.id})`);
  return data;
}

async function autoSetup() {
  console.log('🎨 WEBFLOW CMS AUTO-SETUP');
  console.log('════════════════════════════════════════════════════');
  console.log('');

  try {
    // Get existing collections
    console.log('📥 Fetching existing collections...');
    const existing = await getExistingCollections();
    console.log(`   Found ${existing.length} existing collections`);
    console.log('');

    const existingNames = new Set(
      existing.map(c => c.displayName.toLowerCase())
    );

    // Create missing collections
    const results = {
      created: [],
      skipped: [],
      errors: []
    };

    for (const [key, schema] of Object.entries(COLLECTIONS)) {
      const name = schema.displayName.toLowerCase();
      
      if (existingNames.has(name)) {
        console.log(`⏭️  Skip: ${schema.displayName} (already exists)`);
        results.skipped.push(schema.displayName);
        continue;
      }

      try {
        const collection = await createCollection(schema);
        results.created.push({
          name: schema.displayName,
          id: collection.id
        });
      } catch (error) {
        console.error(`❌ Failed: ${schema.displayName}`);
        console.error(`   ${error.message}`);
        results.errors.push({
          name: schema.displayName,
          error: error.message
        });
      }

      // Rate limiting
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    console.log('');
    console.log('════════════════════════════════════════════════════');
    console.log('📊 SUMMARY');
    console.log('════════════════════════════════════════════════════');
    console.log(`✅ Created: ${results.created.length}`);
    console.log(`⏭️  Skipped: ${results.skipped.length}`);
    console.log(`❌ Errors: ${results.errors.length}`);
    console.log('');

    if (results.created.length > 0) {
      console.log('🆕 New Collections:');
      results.created.forEach(c => {
        console.log(`   - ${c.name}: ${c.id}`);
      });
      console.log('');
      console.log('💡 Update GitHub Secrets with these collection IDs!');
    }

    // Save report
    const fs = require('fs');
    fs.writeFileSync(
      'webflow-setup-report.json',
      JSON.stringify(results, null, 2)
    );
    console.log('✅ Report saved: webflow-setup-report.json');

  } catch (error) {
    console.error('❌ Setup failed:', error.message);
    process.exit(1);
  }
}

autoSetup();
