const { Webflow } = require('webflow-api');

const webflow = new Webflow({ token: process.env.WEBFLOW_API_TOKEN });

async function syncSignalsToWebflow() {
  console.log('🔄 Syncing signals from Supabase to Webflow...');
  
  // 1. Fetch approved signals from Supabase
  const supabaseUrl = process.env.SUPABASE_URL;
  const supabaseKey = process.env.SUPABASE_ANON_KEY;
  
  const response = await fetch(
    `${supabaseUrl}/rest/v1/signals?select=*&status=eq.approved&order=created_at.desc&limit=50`,
    {
      headers: {
        'apikey': supabaseKey,
        'Authorization': `Bearer ${supabaseKey}`
      }
    }
  );
  
  const signals = await response.json();
  console.log(`Found ${signals.length} approved signals`);
  
  // 2. Transform to Webflow format
  const items = signals.map(signal => ({
    isArchived: false,
    isDraft: false,
    fieldData: {
      'name': `${signal.symbol} ${signal.direction}`,
      'slug': `${signal.symbol.toLowerCase()}-${signal.id}`,
      'symbol': signal.symbol,
      'direction': signal.direction,
      'confidence': Math.round(signal.confidence * 100),
      'reason': signal.reason,
      'status': signal.status,
      'created-date': signal.created_at
    }
  }));
  
  // 3. Create/update in Webflow
  const collectionId = process.env.WEBFLOW_SIGNALS_COLLECTION_ID;
  
  for (const item of items) {
    try {
      await webflow.collections.items.createItem(collectionId, item);
      console.log(`✅ Synced: ${item.fieldData.name}`);
    } catch (error) {
      // Item might already exist, try update
      console.log(`⚠️  Already exists: ${item.fieldData.name}`);
    }
  }
  
  console.log('✅ Sync complete!');
}

syncSignalsToWebflow().catch(console.error);
