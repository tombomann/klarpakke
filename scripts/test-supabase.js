require('dotenv').config();

async function testSupabase() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;
  
  console.log('🧪 Testing Supabase connection...');
  console.log(`   URL: ${url}`);
  console.log(`   Key: ${key ? key.substring(0, 20) + '...' : 'MISSING'}`);
  console.log('');
  
  // Test 1: Check if signals table exists
  console.log('📋 Test 1: List tables...');
  try {
    const response = await fetch(
      `${url}/rest/v1/`,
      {
        headers: {
          'apikey': key,
          'Authorization': `Bearer ${key}`
        }
      }
    );
    
    if (response.ok) {
      console.log('✅ API connection successful!');
    } else {
      console.log(`❌ API error: ${response.status}`);
      const error = await response.text();
      console.log(error);
    }
  } catch (error) {
    console.error('❌ Connection failed:', error.message);
  }
  
  console.log('');
  
  // Test 2: Try to fetch signals (without filter)
  console.log('📋 Test 2: Fetch signals table...');
  try {
    const response = await fetch(
      `${url}/rest/v1/signals?select=*&limit=5`,
      {
        headers: {
          'apikey': key,
          'Authorization': `Bearer ${key}`
        }
      }
    );
    
    if (response.ok) {
      const data = await response.json();
      console.log(`✅ Signals table exists! Found ${data.length} rows (showing first 5)`);
      if (data.length > 0) {
        console.log('   Sample:', JSON.stringify(data[0], null, 2));
      }
    } else {
      console.log(`❌ Signals table error: ${response.status}`);
      const error = await response.text();
      console.log(error);
      
      if (response.status === 404) {
        console.log('');
        console.log('💡 Table "signals" does not exist in Supabase');
        console.log('   Create it in Supabase Dashboard or run migrations');
      } else if (response.status === 401) {
        console.log('');
        console.log('💡 Authentication failed. Check:');
        console.log('   1. SUPABASE_URL is correct');
        console.log('   2. SUPABASE_ANON_KEY is valid');
        console.log('   3. RLS policies allow anonymous access');
      }
    }
  } catch (error) {
    console.error('❌ Request failed:', error.message);
  }
}

testSupabase();
