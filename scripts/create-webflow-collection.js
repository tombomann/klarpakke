require('dotenv').config();

async function createCollection() {
  const token = process.env.WEBFLOW_API_TOKEN;
  const siteId = process.env.WEBFLOW_SITE_ID;
  
  if (!token || !siteId) {
    console.error('❌ Missing WEBFLOW_API_TOKEN or WEBFLOW_SITE_ID in .env');
    console.log('');
    console.log('Get these values:');
    console.log('1. API Token: https://webflow.com/dashboard/account/apps');
    console.log('2. Site ID: URL when in Designer → https://webflow.com/design/[SITE_ID]');
    process.exit(1);
  }
  
  const collection = {
    displayName: 'Signals',
    singularName: 'Signal',
    slug: 'signals',
    fields: [
      {
        displayName: 'Symbol',
        slug: 'symbol',
        type: 'PlainText',
        isRequired: true
      },
      {
        displayName: 'Direction',
        slug: 'direction',
        type: 'PlainText',
        isRequired: true
      },
      {
        displayName: 'Confidence',
        slug: 'confidence',
        type: 'Number'
      },
      {
        displayName: 'Reason',
        slug: 'reason',
        type: 'RichText'
      },
      {
        displayName: 'Status',
        slug: 'status',
        type: 'PlainText'
      }
    ]
  };
  
  console.log('🚀 Creating Signals collection in Webflow...');
  console.log(`   Site: ${siteId}`);
  console.log('');
  
  const response = await fetch(
    `https://api.webflow.com/v2/sites/${siteId}/collections`,
    {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Content-Type': 'application/json',
        'accept': 'application/json'
      },
      body: JSON.stringify(collection)
    }
  );
  
  if (response.ok) {
    const result = await response.json();
    console.log('✅ Collection created!');
    console.log(`   ID: ${result.id}`);
    console.log('');
    console.log('📝 Run this command:');
    console.log(`echo "WEBFLOW_SIGNALS_COLLECTION_ID=${result.id}" >> .env`);
    console.log('');
    console.log('Or manually add to .env:');
    console.log(`WEBFLOW_SIGNALS_COLLECTION_ID=${result.id}`);
  } else {
    const error = await response.text();
    console.error('❌ Failed to create collection');
    console.error(`   Status: ${response.status}`);
    console.error(`   Error: ${error}`);
    
    if (response.status === 404) {
      console.log('');
      console.log('💡 Tip: Sjekk at WEBFLOW_SITE_ID er riktig');
      console.log('   Finn den i Designer URL: https://webflow.com/design/[SITE_ID]');
    } else if (response.status === 401) {
      console.log('');
      console.log('💡 Tip: WEBFLOW_API_TOKEN er ugyldig eller utløpt');
      console.log('   Generer ny: https://webflow.com/dashboard/account/apps');
    }
  }
}

createCollection();
