/**
 * Klarpakke Site JavaScript - Enhanced Version
 * Auto-loaded by Webflow loader
 * Version: 2.0.0
 */

(function() {
  'use strict';

  // Configuration
  const CONFIG = window.KLARPAKKE_CONFIG || {};
  const DEBUG = CONFIG.debug || localStorage.getItem('klarpakke_debug') === '1';
  
  // Logger utility
  const log = {
    info: (...args) => DEBUG && console.log('[Klarpakke]', ...args),
    warn: (...args) => console.warn('[Klarpakke]', ...args),
    error: (...args) => console.error('[Klarpakke]', ...args),
  };

  // Validate config
  if (!CONFIG.supabaseUrl || !CONFIG.supabaseAnonKey) {
    log.error('Missing required config:', { 
      hasUrl: !!CONFIG.supabaseUrl, 
      hasKey: !!CONFIG.supabaseAnonKey 
    });
    return;
  }

  log.info('Config loaded:', { 
    supabaseUrl: CONFIG.supabaseUrl,
    debug: DEBUG 
  });

  // Toast utility
  const toast = {
    show: (message, type = 'info') => {
      const toastEl = document.getElementById('kp-toast');
      if (!toastEl) {
        log.warn('Toast element #kp-toast not found');
        return;
      }
      
      toastEl.textContent = message;
      toastEl.className = `kp-toast kp-toast-${type}`;
      toastEl.style.display = 'block';
      
      setTimeout(() => {
        toastEl.style.display = 'none';
      }, 4000);
    },
    success: (msg) => toast.show(msg, 'success'),
    error: (msg) => toast.show(msg, 'error'),
  };

  // API helper
  const api = {
    async call(endpoint, options = {}) {
      const url = `${CONFIG.supabaseUrl}/functions/v1/${endpoint}`;
      const headers = {
        'Authorization': `Bearer ${CONFIG.supabaseAnonKey}`,
        'Content-Type': 'application/json',
        ...options.headers
      };

      log.info(`API call: ${options.method || 'GET'} ${endpoint}`);

      try {
        const response = await fetch(url, { ...options, headers });
        
        if (!response.ok) {
          throw new Error(`HTTP ${response.status}: ${response.statusText}`);
        }

        const data = await response.json();
        log.info(`API response:`, data);
        return { ok: true, data };
      } catch (error) {
        log.error(`API error (${endpoint}):`, error);
        return { ok: false, error: error.message };
      }
    }
  };

  // Path detection
  const rawPath = window.location.pathname || '/';
  const path = rawPath.replace(/\/+$/, '') || '/';
  log.info('Current path:', path);

  // Route-based initialization
  const routes = {
    '/': initLanding,
    '/pricing': initPricing,
    '/app/dashboard': initDashboard,
    '/app/settings': initSettings,
    '/kalkulator': initCalculator,
    '/calculator': initCalculator,
  };

  // Global: Binance referral links
  function initBinanceReferrals() {
    const referralLinks = document.querySelectorAll('[data-kp-ref="binance"], [data-kp-binance-referral]');
    if (referralLinks.length === 0) return;

    referralLinks.forEach(link => {
      link.href = 'https://www.binance.com/en/register?ref=YOUR_REF_CODE';
      link.target = '_blank';
      link.rel = 'noopener noreferrer';
    });

    log.info(`Initialized ${referralLinks.length} Binance referral link(s)`);
  }

  // Landing page
  function initLanding() {
    log.info('Initializing landing page');
    initBinanceReferrals();
  }

  // Pricing page
  function initPricing() {
    log.info('Initializing pricing page');
    
    const planButtons = document.querySelectorAll('[data-plan]');
    if (planButtons.length === 0) {
      log.warn('No pricing buttons found with [data-plan] attribute');
      return;
    }

    planButtons.forEach(button => {
      const plan = button.getAttribute('data-plan');
      
      button.addEventListener('click', (e) => {
        e.preventDefault();
        
        if (plan === 'extrem') {
          window.location.href = '/opplaering?quiz=start';
        } else {
          window.location.href = `/app/settings?plan=${plan}`;
        }
        
        log.info(`Selected plan: ${plan}`);
      });
    });

    log.info(`Initialized ${planButtons.length} pricing button(s)`);
  }

  // Dashboard page
  async function initDashboard() {
    log.info('Initializing dashboard');
    
    const container = document.getElementById('signals-container');
    if (!container) {
      log.warn('Dashboard container #signals-container not found');
      return;
    }

    // Fetch signals
    const result = await api.call('serve-signals');
    
    if (!result.ok) {
      toast.error('Kunne ikke laste signaler');
      container.innerHTML = '<p>Kunne ikke laste signaler. Prøv igjen senere.</p>';
      return;
    }

    const signals = result.data.signals || [];
    
    if (signals.length === 0) {
      container.innerHTML = '<p>Ingen aktive signaler akkurat nå.</p>';
      return;
    }

    // Render signals
    container.innerHTML = signals.map(signal => `
      <div class="signal-card" data-signal-id="${signal.id}">
        <h3>${signal.symbol}</h3>
        <p>Type: ${signal.action}</p>
        <p>Pris: ${signal.price}</p>
        <button class="btn-approve" data-id="${signal.id}">Godkjenn</button>
        <button class="btn-reject" data-id="${signal.id}">Avvis</button>
      </div>
    `).join('');

    // Event delegation for approve/reject
    container.addEventListener('click', async (e) => {
      if (!e.target.matches('.btn-approve, .btn-reject')) return;
      
      const signalId = e.target.getAttribute('data-id');
      const action = e.target.classList.contains('btn-approve') ? 'approve' : 'reject';
      
      log.info(`Signal ${action}:`, signalId);
      
      const result = await api.call('approve-signal', {
        method: 'POST',
        body: JSON.stringify({ signal_id: signalId, action })
      });

      if (result.ok) {
        toast.success(action === 'approve' ? 'Signal godkjent' : 'Signal avvist');
        e.target.closest('.signal-card').remove();
      } else {
        toast.error('Noe gikk galt');
      }
    });

    log.info(`Rendered ${signals.length} signal(s)`);
  }

  // Settings page
  function initSettings() {
    log.info('Initializing settings');
    
    const saveBtn = document.getElementById('save-settings');
    const planSelect = document.getElementById('plan-select');
    const compoundToggle = document.getElementById('compound-toggle');

    if (!saveBtn) {
      log.warn('Settings button #save-settings not found');
      return;
    }

    // Pre-fill from URL params
    const urlParams = new URLSearchParams(window.location.search);
    const preselectedPlan = urlParams.get('plan');
    
    if (preselectedPlan && planSelect) {
      planSelect.value = preselectedPlan;
      log.info('Pre-selected plan:', preselectedPlan);
    }

    saveBtn.addEventListener('click', async () => {
      const settings = {
        plan: planSelect?.value || 'paper',
        compound: compoundToggle?.checked || false
      };

      log.info('Saving settings:', settings);

      // TODO: Call API to save settings
      // For now, just localStorage
      localStorage.setItem('klarpakke_settings', JSON.stringify(settings));
      
      toast.success('Innstillinger lagret');
    });
  }

  // Calculator page (basic structure - full logic in calculator.js)
  function initCalculator() {
    log.info('Initializing calculator');
    
    const requiredIds = ['calc-start', 'calc-crypto-percent', 'calc-plan', 'calc-result-table'];
    const missing = requiredIds.filter(id => !document.getElementById(id));
    
    if (missing.length > 0) {
      log.warn('Calculator missing elements:', missing);
      return;
    }

    log.info('Calculator elements found - full logic in calculator.js');
  }

  // Initialize
  function init() {
    log.info('Initialized');
    
    // Check for route-specific init
    const initFn = routes[path];
    if (initFn) {
      initFn();
    } else {
      log.info('No route-specific init for:', path);
      initBinanceReferrals(); // Global fallback
    }
  }

  // Wait for DOM ready
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

})();
