#!/usr/bin/env node
/**
 * Webflow Custom Code Snippet Generator
 * Generates ready-to-paste HTML snippets for Webflow
 */

const fs = require('fs');
const path = require('path');

const SNIPPETS_DIR = path.join(__dirname, '..', 'web', 'snippets');

// Ensure directory exists
if (!fs.existsSync(SNIPPETS_DIR)) {
  fs.mkdirSync(SNIPPETS_DIR, { recursive: true });
}

const snippets = {
  'dashboard-page-head.html': `<!-- Klarpakke Dashboard - HEAD Code -->
<meta name="klarpakke:page" content="dashboard">
<style>
  /* Loading spinner */
  .kp-loader {
    text-align: center;
    padding: 2rem;
    color: #666;
  }
  
  /* Signal cards */
  .signal-card {
    background: white;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    padding: 1.5rem;
    margin-bottom: 1rem;
    transition: all 0.3s;
  }
  
  .signal-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  }
  
  .signal-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 1rem;
  }
  
  .signal-header h3 {
    margin: 0;
    font-size: 1.25rem;
  }
  
  .badge {
    display: inline-block;
    padding: 0.25rem 0.75rem;
    border-radius: 4px;
    font-size: 0.875rem;
    font-weight: 600;
    margin-left: 0.5rem;
  }
  
  .badge.buy {
    background: #10b981;
    color: white;
  }
  
  .badge.sell {
    background: #ef4444;
    color: white;
  }
  
  .confidence {
    font-size: 1.5rem;
    font-weight: 700;
    color: #3b82f6;
  }
  
  .actions {
    display: flex;
    gap: 0.5rem;
    margin-top: 1rem;
  }
  
  .actions button {
    flex: 1;
    padding: 0.75rem;
    border: none;
    border-radius: 6px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
  }
  
  .btn-approve {
    background: #10b981;
    color: white;
  }
  
  .btn-approve:hover {
    background: #059669;
  }
  
  .btn-reject {
    background: #ef4444;
    color: white;
  }
  
  .btn-reject:hover {
    background: #dc2626;
  }
  
  button:disabled {
    opacity: 0.5;
    cursor: not-allowed;
  }
  
  /* Toast */
  #kp-toast {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    background: #1f2937;
    color: white;
    padding: 1rem 1.5rem;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.3);
    display: none;
    z-index: 9999;
  }
  
  #kp-toast[data-type="success"] {
    background: #10b981;
  }
  
  #kp-toast[data-type="error"] {
    background: #ef4444;
  }
</style>`,

  'dashboard-page-body.html': `<!-- Klarpakke Dashboard - BODY Code -->
<div id="signals-container">
  <!-- Signals will be loaded here by JavaScript -->
</div>

<!-- Toast notification (global) -->
<div id="kp-toast"></div>

<!-- Optional: Filter buttons -->
<div class="signal-filters" style="margin-bottom: 1rem; display: flex; gap: 0.5rem;">
  <button id="filter-all" class="filter-btn active">All</button>
  <button id="filter-buy" class="filter-btn">BUY Only</button>
  <button id="filter-sell" class="filter-btn">SELL Only</button>
</div>`,

  'settings-page-body.html': `<!-- Klarpakke Settings - BODY Code -->
<form id="settings-form" style="max-width: 600px;">
  <div class="form-group" style="margin-bottom: 1.5rem;">
    <label for="plan-select" style="display: block; margin-bottom: 0.5rem; font-weight: 600;">
      Trading Plan
    </label>
    <select id="plan-select" style="width: 100%; padding: 0.75rem; border: 1px solid #e0e0e0; border-radius: 6px;">
      <option value="paper">Paper (Demo)</option>
      <option value="safe">Safe</option>
      <option value="pro">Pro</option>
      <option value="extrem">Ekstrem</option>
    </select>
  </div>
  
  <div class="form-group" style="margin-bottom: 1.5rem;">
    <label style="display: flex; align-items: center; gap: 0.5rem; cursor: pointer;">
      <input type="checkbox" id="compound-toggle" style="width: 1.25rem; height: 1.25rem;">
      <span style="font-weight: 600;">Enable Compounding</span>
    </label>
    <p style="margin-top: 0.5rem; font-size: 0.875rem; color: #666;">
      Reinvest profits automatically for exponential growth
    </p>
  </div>
  
  <button 
    type="button" 
    id="save-settings" 
    style="width: 100%; padding: 1rem; background: #3b82f6; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">
    Save Settings
  </button>
</form>

<div id="kp-toast"></div>`,

  'calculator-page-body.html': `<!-- Klarpakke Calculator - BODY Code -->
<!-- See web/calculator.js for full implementation -->
<div class="calculator-container" style="max-width: 600px; margin: 0 auto;">
  <div class="form-group" style="margin-bottom: 1rem;">
    <label for="calc-start">Starting Amount (NOK)</label>
    <input type="number" id="calc-start" value="10000" min="1000" step="1000">
  </div>
  
  <div class="form-group" style="margin-bottom: 1rem;">
    <label for="calc-crypto-percent">Crypto Allocation (%)</label>
    <input type="range" id="calc-crypto-percent" value="50" min="0" max="100">
    <span id="crypto-percent-label">50%</span>
  </div>
  
  <div class="form-group" style="margin-bottom: 1rem;">
    <label for="calc-plan">Trading Plan</label>
    <select id="calc-plan">
      <option value="safe">Safe</option>
      <option value="pro">Pro</option>
      <option value="extrem">Ekstrem</option>
    </select>
  </div>
  
  <button id="calc-calculate-btn" style="width: 100%; padding: 1rem; background: #10b981; color: white; border: none; border-radius: 6px; font-weight: 600; cursor: pointer;">
    Calculate Risk
  </button>
  
  <div id="calc-result-table" style="margin-top: 2rem; display: none;">
    <!-- Results will be populated by calculator.js -->
  </div>
</div>`,

  'footer-loader-production.html': `<!-- Klarpakke Footer Loader (Production) -->
<script>
  // Runtime configuration (injected by build)
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: 'https://swfyuwkptusceiouqlks.supabase.co',
    supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3Znl1d2twdHVzY2Vpb3VxbGtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxODY4MDEsImV4cCI6MjA4NDc2MjgwMX0.ZSpSU8pkIDxY0DrBKRitID2Sx6OUUGy1D4bFMVSwWlk',
    debug: false,
    environment: 'production'
  };
</script>

<!-- Load main site engine -->
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/klarpakke-site.js"></script>

<!-- Load calculator (for /kalkulator page) -->
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/calculator.js"></script>

<!-- Optional: Analytics -->
<!-- <script>
  // Add Google Analytics or similar here
</script> -->`
};

console.log('📝 Generating Webflow custom code snippets...');
console.log('');

let generated = 0;

for (const [filename, content] of Object.entries(snippets)) {
  const filepath = path.join(SNIPPETS_DIR, filename);
  fs.writeFileSync(filepath, content);
  console.log(`✅ Generated: ${filename}`);
  generated++;
}

console.log('');
console.log('════════════════════════════════════════════════════');
console.log(`✅ Generated ${generated} snippets in: ${SNIPPETS_DIR}`);
console.log('');
console.log('📋 NEXT STEPS:');
console.log('1. Open Webflow Designer');
console.log('2. For each page:');
console.log('   - Add HEAD code from *-head.html');
console.log('   - Add BODY code from *-body.html');
console.log('3. In Project Settings → Custom Code → Footer:');
console.log('   - Paste footer-loader-production.html');
console.log('4. Publish site');
console.log('');

process.exit(0);
