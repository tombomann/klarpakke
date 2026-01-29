require('dotenv').config();

async function syncSignals() {
  console.log('🔄 Starting sync...');
  
  const required = {
    SUPABASE_URL: process.env.SUPABASE_URL,
    SUPABASE_ANON_KEY: process.env.SUPABASE_ANON_KEY,
    WEBFLOW_API_TOKEN: process.env.WEBFLOW_API_TOKEN,
    WEBFLOW_SIGNALS_COLLECTION_ID: process.env.WEBFLOW_SIGNALS_COLLECTION_ID
  };
  
  for (const [key, value] of Object.entries(required)) {
    if (!value) {
      console.error(`❌ Missing ${key} in .env`);
      process.exit(1);
    }
  }
  
  try {
    console.log('📥 Fetching signals from Supabase...');
    const supabaseRes = await fetch(
      `${required.SUPABASE_URL}/rest/v1/signals?select=*&order=created_at.desc&limit=10`,
      {
        headers: {
          'apikey': required.SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${required.SUPABASE_ANON_KEY}`
        }
      }
    );
    
    if (!supabaseRes.ok) {
      const error = await supabaseRes.text();
      throw new Error(`Supabase error: ${supabaseRes.status} - ${error}`);
    }
    
    const signals = await supabaseRes.json();
    console.log(`✅ Found ${signals.length} signals`);
    
    if (signals.length === 0) {
      console.log('⚠️  No signals to sync');
      return;
    }
    
    // Fetch existing Webflow items
    console.log('📥 Checking Webflow collection...');
    const webflowListRes = await fetch(
      `https://api.webflow.com/v2/collections/${required.WEBFLOW_SIGNALS_COLLECTION_ID}/items`,
      {
        headers: {
          'Authorization': `Bearer ${required.WEBFLOW_API_TOKEN}`,
          'accept': 'application/json'
        }
      }
    );
    
    if (!webflowListRes.ok) {
      const error = await webflowListRes.text();
      throw new Error(`Webflow list error: ${webflowListRes.status} - ${error}`);
    }
    
    const existing = await webflowListRes.json();
    const existingSlugs = new Set(
      (existing.items || []).map(item => item.fieldData?.slug || item.slug)
    );
    
    console.log(`Found ${existingSlugs.size} existing items in Webflow`);
    console.log('');
    
    let synced = 0;
    let skipped = 0;
    let errors = 0;
    
    for (const signal of signals) {
      // SKIP signals without symbol
      if (!signal.symbol || signal.symbol.trim() === '') {
        console.log(`⏭️  Skip: Empty symbol (ID: ${signal.id.substring(0, 8)})`);
        skipped++;
        continue;
      }
      
      const slug = `${signal.symbol.toLowerCase()}-${signal.id.substring(0, 8)}`;
      
      if (existingSlugs.has(slug)) {
        console.log(`⏭️  Skip: ${signal.symbol} (exists)`);
        skipped++;
        continue;
      }
      
      const item = {
        isArchived: false,
        isDraft: false,
        fieldData: {
          name: `${signal.symbol} ${signal.direction}`,
          slug: slug,
          symbol: signal.symbol,
          direction: signal.direction,
          confidence: Math.round((signal.confidence || 0) * 100),
          reason: signal.reason || 'No reason provided',
          status: signal.status || 'pending'
        }
      };
      
      console.log(`📤 Creating: ${signal.symbol} ${signal.direction}...`);
      
      const createRes = await fetch(
        `https://api.webflow.com/v2/collections/${required.WEBFLOW_SIGNALS_COLLECTION_ID}/items`,
        {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${required.WEBFLOW_API_TOKEN}`,
            'Content-Type': 'application/json',
            'accept': 'application/json'
          },
          body: JSON.stringify(item)
        }
      );
      
      if (createRes.ok) {
        console.log(`✅ Synced: ${signal.symbol} ${signal.direction}`);
        synced++;
      } else {
        const error = await createRes.text();
        console.error(`❌ Failed: ${signal.symbol} - ${error}`);
        errors++;
      }
      
      await new Promise(resolve => setTimeout(resolve, 200));
    }
    
    console.log('');
    console.log('════════════════════════════════════════');
    console.log('✅ SYNC COMPLETE!');
    console.log(`   Synced: ${synced}`);
    console.log(`   Skipped: ${skipped}`);
    console.log(`   Errors: ${errors}`);
    console.log(`   Total: ${signals.length}`);
    console.log('════════════════════════════════════════');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

syncSignals();
