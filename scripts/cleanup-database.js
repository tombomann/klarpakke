#!/usr/bin/env node
/**
 * Database Cleanup Script
 * Removes invalid signals and reports statistics
 */

require('dotenv').config();

const SUPABASE_URL = process.env.SUPABASE_URL;
const SUPABASE_ANON_KEY = process.env.SUPABASE_ANON_KEY;

if (!SUPABASE_URL || !SUPABASE_ANON_KEY) {
  console.error('❌ Missing SUPABASE_URL or SUPABASE_ANON_KEY');
  process.exit(1);
}

async function cleanupDatabase() {
  console.log('🧹 Starting database cleanup...');
  console.log('');

  try {
    // 1. Fetch all signals
    console.log('📥 Fetching all signals...');
    const response = await fetch(`${SUPABASE_URL}/rest/v1/signals?select=*`, {
      headers: {
        'apikey': SUPABASE_ANON_KEY,
        'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
      }
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const signals = await response.json();
    console.log(`✅ Found ${signals.length} total signals`);
    console.log('');

    // 2. Find invalid signals
    const invalidSignals = signals.filter(s => 
      !s.symbol || s.symbol.trim() === ''
    );

    if (invalidSignals.length === 0) {
      console.log('✅ No invalid signals found!');
      console.log('   Database is clean.');
      return;
    }

    console.log(`⚠️  Found ${invalidSignals.length} invalid signals:`);
    invalidSignals.forEach(s => {
      console.log(`   - ID: ${s.id.substring(0, 8)}... (symbol: "${s.symbol || 'null'}")`);
    });
    console.log('');

    // 3. Delete invalid signals
    console.log('🗑️  Deleting invalid signals...');
    let deleted = 0;

    for (const signal of invalidSignals) {
      const deleteResponse = await fetch(
        `${SUPABASE_URL}/rest/v1/signals?id=eq.${signal.id}`,
        {
          method: 'DELETE',
          headers: {
            'apikey': SUPABASE_ANON_KEY,
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
            'Prefer': 'return=minimal'
          }
        }
      );

      if (deleteResponse.ok || deleteResponse.status === 204) {
        deleted++;
        console.log(`   ✅ Deleted: ${signal.id.substring(0, 8)}...`);
      } else {
        console.log(`   ❌ Failed: ${signal.id.substring(0, 8)}...`);
      }

      // Rate limiting
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    console.log('');
    console.log('════════════════════════════════════════');
    console.log('✅ CLEANUP COMPLETE!');
    console.log(`   Deleted: ${deleted}/${invalidSignals.length}`);
    console.log(`   Remaining: ${signals.length - deleted}`);
    console.log('════════════════════════════════════════');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

cleanupDatabase();
