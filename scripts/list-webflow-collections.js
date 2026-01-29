require('dotenv').config();

async function listCollections() {
  const token = process.env.WEBFLOW_API_TOKEN;
  const siteId = process.env.WEBFLOW_SITE_ID;
  
  if (!token || !siteId) {
    console.error('❌ Missing credentials in .env');
    process.exit(1);
  }
  
  console.log('📥 Fetching collections...');
  console.log(`   Site: ${siteId}`);
  console.log('');
  
  const response = await fetch(
    `https://api.webflow.com/v2/sites/${siteId}/collections`,
    {
      headers: {
        'Authorization': `Bearer ${token}`,
        'accept': 'application/json'
      }
    }
  );
  
  if (response.ok) {
    const result = await response.json();
    console.log(`✅ Found ${result.collections.length} collections:\n`);
    
    result.collections.forEach(col => {
      console.log(`   📦 ${col.displayName}`);
      console.log(`      ID: ${col.id}`);
      console.log(`      Slug: ${col.slug}`);
      console.log('');
    });
    
    const signalsCol = result.collections.find(c => 
      c.displayName === 'Signals' || c.slug === 'signals'
    );
    
    if (signalsCol) {
      console.log('════════════════════════════════════════');
      console.log('🎯 FOUND SIGNALS COLLECTION!');
      console.log('════════════════════════════════════════');
      console.log(`ID: ${signalsCol.id}`);
      console.log('');
      console.log('📝 Run this command to add to .env:');
      console.log('');
      console.log(`echo "WEBFLOW_SIGNALS_COLLECTION_ID=${signalsCol.id}" >> .env`);
      console.log('');
    }
  } else {
    const error = await response.text();
    console.error(`❌ Error: ${response.status}`);
    console.error(error);
  }
}

listCollections();
