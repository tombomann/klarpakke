#!/usr/bin/env node
/**
 * Generate Webflow Loader
 * - Reads config from env vars (GitHub Secrets)
 * - Generates self-contained loader script
 * - Injects into Webflow as single <script> tag
 * - No external dependencies, no inline keys
 */

const fs = require('fs');
const path = require('path');

const WEBFLOW_LOADER_TEMPLATE = `
/**
 * Klarpakke Webflow Loader
 * Auto-generated - Do not edit manually
 * Version: {VERSION}
 * Timestamp: {TIMESTAMP}
 */
(function() {
  'use strict';

  // Prevent double-execution
  if (window.__KLARPAKKE_LOADER__) return;
  window.__KLARPAKKE_LOADER__ = true;

  // Inject config from meta tags or environment
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: '{SUPABASE_URL}',
    supabaseAnonKey: '{SUPABASE_ANON_KEY}',
    version: '{VERSION}',
    timestamp: '{TIMESTAMP}',
    debug: {DEBUG}
  };

  console.log('[Klarpakke Loader] Config initialized', {
    supabaseUrl: window.KLARPAKKE_CONFIG.supabaseUrl,
    version: window.KLARPAKKE_CONFIG.version
  });

  /**
   * Load script async with timeout
   */
  function loadScript(src, timeout = 10000) {
    return new Promise((resolve, reject) => {
      const script = document.createElement('script');
      script.src = src;
      script.async = true;
      
      const timer = setTimeout(() => {
        reject(new Error(`Script load timeout: \${src}`));
      }, timeout);

      script.onload = () => {
        clearTimeout(timer);
        console.log('[Klarpakke Loader] Loaded:', src);
        resolve();
      };

      script.onerror = () => {
        clearTimeout(timer);
        reject(new Error(`Failed to load: \${src}`));
      };

      document.body.appendChild(script);
    });
  }

  /**
   * Initialize on DOM ready
   */
  function onReady() {
    // Load main site engine
    loadScript('{CDN_URL}/web/klarpakke-site.js')
      .then(() => {
        console.log('[Klarpakke Loader] Site engine ready');
        // Load calculator if on kalkulator page
        if (window.location.pathname.includes('/kalkulator')) {
          return loadScript('{CDN_URL}/web/calculator.js');
        }
      })
      .catch((err) => {
        console.error('[Klarpakke Loader] Error:', err);
      });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', onReady);
  } else {
    onReady();
  }
})();
`;

function generateLoader() {
  const version = process.env.GITHUB_SHA || 'dev';
  const timestamp = new Date().toISOString();
  const supabaseUrl = process.env.SUPABASE_URL || '';
  const supabaseAnonKey = process.env.SUPABASE_ANON_KEY || '';
  const cdnUrl = process.env.CDN_URL || `https://cdn.jsdelivr.net/gh/tombomann/klarpakke@${version}`;
  const debug = process.env.DEBUG === 'true' ? 'true' : 'false';

  if (!supabaseUrl || !supabaseAnonKey) {
    console.warn('\u26a0\ufe0f  Warning: Missing Supabase environment variables');
    console.warn('  Expected: SUPABASE_URL, SUPABASE_ANON_KEY');
  }

  let loader = WEBFLOW_LOADER_TEMPLATE
    .replace('{VERSION}', version)
    .replace('{TIMESTAMP}', timestamp)
    .replace('{SUPABASE_URL}', supabaseUrl)
    .replace('{SUPABASE_ANON_KEY}', supabaseAnonKey)
    .replace('{CDN_URL}', cdnUrl)
    .replace('{DEBUG}', debug);

  // Output path
  const outputDir = path.join(__dirname, '..', 'web', 'dist');
  if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
  }

  const outputPath = path.join(outputDir, 'webflow-loader.js');
  fs.writeFileSync(outputPath, loader);

  console.log('\u2713 Webflow loader generated:');
  console.log(`  Path: ${outputPath}`);
  console.log(`  Size: ${loader.length} bytes`);
  console.log(`  Version: ${version}`);
  console.log(`  CDN: ${cdnUrl}`);
  console.log('');
  console.log('Webflow Setup Instructions:');
  console.log('1. Open Webflow site settings');
  console.log('2. Go to Custom Code > Footer');
  console.log('3. Paste this in Footer:');
  console.log('');
  console.log(`<script src="${cdnUrl}/web/dist/webflow-loader.js"><\/script>`);
  console.log('');
  console.log('4. Save and publish');

  // Also output to web/loader.js for easy access
  const altPath = path.join(__dirname, '..', 'web', 'loader.js');
  fs.writeFileSync(altPath, loader);
  console.log(`\u2713 Also saved to: ${altPath}`);
}

generateLoa der();
