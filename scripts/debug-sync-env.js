require('dotenv').config();

console.log('🔍 DEBUG: Environment variables in sync script');
console.log('');
console.log('SUPABASE_URL:', process.env.SUPABASE_URL ? 'SET' : 'MISSING');
console.log('SUPABASE_ANON_KEY length:', process.env.SUPABASE_ANON_KEY?.length || 0);
console.log('SUPABASE_ANON_KEY preview:', process.env.SUPABASE_ANON_KEY?.substring(0, 30) + '...');
console.log('');

// Test med samme key som sync bruker
async function testKey() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;
  
  console.log('Testing Supabase with these credentials...');
  
  const response = await fetch(
    `${url}/rest/v1/signals?select=*&status=eq.approved&limit=1`,
    {
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`
      }
    }
  );
  
  console.log('Status:', response.status);
  
  if (response.ok) {
    const data = await response.json();
    console.log('✅ Success! Found', data.length, 'signals');
  } else {
    const error = await response.text();
    console.log('❌ Error:', error);
  }
}

testKey();
