#!/usr/bin/env node
/**
 * System Health Check Script
 * Validates all integrations and reports status
 */

require('dotenv').config();

const checks = [];

async function checkSupabase() {
  const url = process.env.SUPABASE_URL;
  const key = process.env.SUPABASE_ANON_KEY;

  if (!url || !key) {
    return { name: 'Supabase', status: 'fail', message: 'Missing credentials' };
  }

  try {
    const response = await fetch(`${url}/rest/v1/signals?select=count`, {
      headers: {
        'apikey': key,
        'Authorization': `Bearer ${key}`
      }
    });

    if (response.ok) {
      const data = await response.json();
      return { 
        name: 'Supabase', 
        status: 'pass', 
        message: `${data.length > 0 ? data[0].count : 0} signals` 
      };
    } else {
      return { name: 'Supabase', status: 'fail', message: `HTTP ${response.status}` };
    }
  } catch (error) {
    return { name: 'Supabase', status: 'fail', message: error.message };
  }
}

async function checkWebflow() {
  const token = process.env.WEBFLOW_API_TOKEN;
  const siteId = process.env.WEBFLOW_SITE_ID;

  if (!token || !siteId) {
    return { name: 'Webflow', status: 'fail', message: 'Missing credentials' };
  }

  try {
    const response = await fetch(`https://api.webflow.com/v2/sites/${siteId}`, {
      headers: {
        'Authorization': `Bearer ${token}`
      }
    });

    if (response.ok) {
      const data = await response.json();
      return { 
        name: 'Webflow', 
        status: 'pass', 
        message: `Site: ${data.displayName || 'Unknown'}` 
      };
    } else {
      return { name: 'Webflow', status: 'fail', message: `HTTP ${response.status}` };
    }
  } catch (error) {
    return { name: 'Webflow', status: 'fail', message: error.message };
  }
}

async function runHealthCheck() {
  console.log('🏥 SYSTEM HEALTH CHECK');
  console.log('════════════════════════════════════════');
  console.log('');

  const results = await Promise.all([
    checkSupabase(),
    checkWebflow()
  ]);

  let allPassed = true;

  results.forEach(result => {
    const icon = result.status === 'pass' ? '✅' : '❌';
    console.log(`${icon} ${result.name}: ${result.message}`);
    if (result.status === 'fail') allPassed = false;
  });

  console.log('');
  console.log('════════════════════════════════════════');
  
  if (allPassed) {
    console.log('✅ ALL SYSTEMS OPERATIONAL');
    process.exit(0);
  } else {
    console.log('❌ SOME SYSTEMS FAILED');
    process.exit(1);
  }
}

runHealthCheck();
