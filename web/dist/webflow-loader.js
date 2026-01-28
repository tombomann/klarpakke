
/**
 * Klarpakke Webflow Loader
 * Auto-generated - Do not edit manually
 * Version: dev
 * Timestamp: 2026-01-28T04:52:34.005Z
 */
(function() {
  'use strict';

  // Prevent double-execution
  if (window.__KLARPAKKE_LOADER__) return;
  window.__KLARPAKKE_LOADER__ = true;

  // Inject config from meta tags or environment
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: '',
    supabaseAnonKey: '',
    version: 'dev',
    timestamp: '2026-01-28T04:52:34.005Z',
    debug: false
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
        reject(new Error('Script load timeout: ' + src));
      }, timeout);

      script.onload = () => {
        clearTimeout(timer);
        console.log('[Klarpakke Loader] Loaded:', src);
        resolve();
      };

      script.onerror = () => {
        clearTimeout(timer);
        reject(new Error('Failed to load: ' + src));
      };

      document.body.appendChild(script);
    });
  }

  /**
   * Initialize on DOM ready
   */
  function onReady() {
    // Load main site engine
    loadScript('https://cdn.jsdelivr.net/gh/tombomann/klarpakke@dev/web/klarpakke-site.js')
      .then(() => {
        console.log('[Klarpakke Loader] Site engine ready');
        // Load calculator if on kalkulator page
        if (window.location.pathname.includes('/kalkulator')) {
          return loadScript('https://cdn.jsdelivr.net/gh/tombomann/klarpakke@dev/web/calculator.js');
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
