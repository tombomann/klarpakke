// Klarpakke Site Engine v2.2
// Webflow master script (landing + app)
// Key change: runtime config (no hardcoded Supabase URL/keys) + DOM-ready init

(function () {
  'use strict';

  // Prevent double-execution (Webflow can re-run scripts on publish changes / embeds)
  if (window.__KLARPAKKE_SITE_ENGINE__) return;
  window.__KLARPAKKE_SITE_ENGINE__ = true;

  const DEFAULTS = {
    debug: false,
    fetchTimeoutMs: 15000,
  };

  function getMeta(name) {
    const el = document.querySelector(`meta[name="${name}"]`);
    return el ? el.getAttribute('content') : null;
  }

  function getConfig() {
    const fromWindow = window.KLARPAKKE_CONFIG || window.klarpakkeConfig || {};
    const fromMeta = {
      supabaseUrl: getMeta('klarpakke:supabase-url'),
      supabaseAnonKey: getMeta('klarpakke:supabase-anon-key'),
      debug: getMeta('klarpakke:debug'),
    };
    const fromBody = document.body
      ? {
          supabaseUrl: document.body.dataset.supabaseUrl,
          supabaseAnonKey: document.body.dataset.supabaseAnonKey,
          debug: document.body.dataset.klarpakkeDebug,
        }
      : {};

    const cfg = Object.assign({}, DEFAULTS, fromBody, fromMeta, fromWindow);

    // Normalize
    if (typeof cfg.debug === 'string') cfg.debug = cfg.debug === '1' || cfg.debug === 'true';
    if (cfg.supabaseUrl) cfg.supabaseUrl = String(cfg.supabaseUrl).replace(/\/$/, '');

    // Local debug override
    try {
      if (localStorage.getItem('klarpakke_debug') === '1') cfg.debug = true;
    } catch (_) {}

    return cfg;
  }

  const config = getConfig();

  const logger = {
    debug: (...args) => (config.debug ? console.debug('[Klarpakke]', ...args) : undefined),
    info: (...args) => console.info('[Klarpakke]', ...args),
    warn: (...args) => console.warn('[Klarpakke]', ...args),
    error: (...args) => console.error('[Klarpakke]', ...args),
  };

  function toast(message, type) {
    const el = document.getElementById('kp-toast');
    if (!el) {
      // Fallback (avoid alert spam unless really needed)
      if (type === 'error') alert(message);
      return;
    }
    el.textContent = message;
    el.style.display = 'block';
    el.setAttribute('data-type', type || 'info');
    setTimeout(() => {
      el.style.display = 'none';
    }, 3500);
  }

  function requireSupabaseConfig() {
    if (!config.supabaseUrl || !config.supabaseAnonKey) {
      logger.warn(
        'Missing Supabase runtime config. Provide via window.KLARPAKKE_CONFIG, <meta>, or <body data-*>.\n' +
          'Expected: supabaseUrl + supabaseAnonKey.'
      );
      return false;
    }
    return true;
  }

  async function fetchJson(url, options) {
    const ctrl = new AbortController();
    const t = setTimeout(() => ctrl.abort(), config.fetchTimeoutMs || 15000);

    try {
      const res = await fetch(url, Object.assign({}, options, { signal: ctrl.signal }));
      if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
      return await res.json();
    } finally {
      clearTimeout(t);
    }
  }

  function onReady(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn, { once: true });
    } else {
      fn();
    }
  }

  const path = window.location.pathname || '/';
  const isDashboard = path.includes('/dashboard');
  const isSettings = path.includes('/settings');
  const isPricing = path.includes('/pricing');
  const isCalculator = path.includes('/kalkulator');

  logger.info('Site engine v2.2 loaded');
  logger.debug('Path:', path, 'Config:', { ...config, supabaseAnonKey: config.supabaseAnonKey ? '***' : null });

  // ═══════════════════════════════════════════════════════════
  // DASHBOARD: Fetch + Display Signals
  // ═══════════════════════════════════════════════════════════
  function initDashboard() {
    logger.info('Dashboard mode');

    const container = document.getElementById('signals-container');
    if (!container) {
      logger.warn('No #signals-container found on page');
      return;
    }

    async function loadSignals() {
      if (!requireSupabaseConfig()) {
        container.innerHTML = '<p style="color:#b45309;">Dashboard er ikke konfigurert (mangler Supabase config).</p>';
        return;
      }

      container.innerHTML = '<p>Laster signaler…</p>';

      try {
        const url = `${config.supabaseUrl}/rest/v1/signals?select=*&status=eq.pending&order=created_at.desc&limit=20`;
        const signals = await fetchJson(url, {
          headers: {
            apikey: config.supabaseAnonKey,
            Authorization: `Bearer ${config.supabaseAnonKey}`,
          },
        });

        logger.info('Loaded signals:', signals.length);

        if (!Array.isArray(signals) || signals.length === 0) {
          container.innerHTML = '<p>Ingen pending signals akkurat nå.</p>';
          return;
        }

        container.innerHTML = signals
          .map(
            (signal) => `
          <div class="signal-card" data-signal-id="${signal.id}">
            <div class="signal-header">
              <span class="symbol">${signal.symbol || ''}</span>
              <span class="direction ${(signal.direction || '').toLowerCase()}">${signal.direction || ''}</span>
            </div>
            <div class="signal-body">
              <p class="reason">${signal.reason || ''}</p>
              <div class="meta">
                <span>Confidence: ${signal.confidence != null ? Math.round(signal.confidence * 100) : 0}%</span>
                <span>Model: ${signal.ai_model || 'unknown'}</span>
              </div>
            </div>
            <div class="signal-actions">
              <button class="btn-approve" data-action="approve" data-signal-id="${signal.id}">
                Approve
              </button>
              <button class="btn-reject" data-action="reject" data-signal-id="${signal.id}">
                Reject
              </button>
            </div>
          </div>
        `
          )
          .join('');
      } catch (err) {
        logger.error('Error loading signals:', err);
        container.innerHTML = `<p style="color:#b91c1c;">Klarte ikke å laste signaler: ${err.message}</p>`;
      }
    }

    // Click delegation for approve/reject
    document.addEventListener('click', async function (e) {
      const btn = e.target.closest('[data-action]');
      if (!btn) return;

      const action = btn.dataset.action;
      const signalId = btn.dataset.signalId;
      if (!action || !signalId) return;

      if (!requireSupabaseConfig()) {
        toast('Mangler Supabase config – kan ikke utføre handling.', 'error');
        return;
      }

      logger.info(`${action} signal ${signalId}`);

      btn.disabled = true;
      const originalText = btn.textContent;
      btn.textContent = action === 'approve' ? 'Approving…' : 'Rejecting…';

      try {
        const url = `${config.supabaseUrl}/functions/v1/approve-signal`;
        const data = await fetchJson(url, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${config.supabaseAnonKey}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ signal_id: signalId, action: String(action).toUpperCase() }),
        });

        logger.debug('Approve/reject response:', data);
        btn.textContent = action === 'approve' ? 'Approved' : 'Rejected';

        setTimeout(() => {
          const card = btn.closest('.signal-card');
          if (card) card.remove();
        }, 1200);
      } catch (err) {
        logger.error('Approve/reject failed:', err);
        btn.textContent = originalText;
        btn.disabled = false;
        toast(`Feil: ${err.message}`, 'error');
      }
    });

    loadSignals();
  }

  // ═══════════════════════════════════════════════════════════
  // SETTINGS: Plan Selection + Compounding Toggle
  // ═══════════════════════════════════════════════════════════
  function initSettings() {
    logger.info('Settings mode');

    const saveBtn = document.getElementById('save-settings');
    if (!saveBtn) {
      logger.warn('No #save-settings found');
      return;
    }

    saveBtn.addEventListener('click', async function () {
      const plan = document.getElementById('plan-select')?.value || null;
      const compounding = !!document.getElementById('compound-toggle')?.checked;

      logger.info('Save settings:', { plan, compounding });

      // Best-effort backend call (function may not exist in all envs)
      if (requireSupabaseConfig()) {
        try {
          const url = `${config.supabaseUrl}/functions/v1/update-user-settings`;
          await fetchJson(url, {
            method: 'POST',
            headers: {
              Authorization: `Bearer ${config.supabaseAnonKey}`,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ user_id: 'demo-user', plan, compounding_enabled: compounding }),
          });
          toast('Settings saved', 'info');
          return;
        } catch (err) {
          logger.warn('update-user-settings failed; falling back to localStorage:', err);
        }
      }

      // Fallback
      try {
        localStorage.setItem('klarpakke_plan', plan || '');
        localStorage.setItem('klarpakke_compounding', compounding ? '1' : '0');
      } catch (_) {}
      toast('Settings saved (local)', 'info');
    });
  }

  // ═══════════════════════════════════════════════════════════
  // PRICING: Plan Selection (EXTREM requires quiz)
  // ═══════════════════════════════════════════════════════════
  function initPricing() {
    logger.info('Pricing mode');

    document.addEventListener('click', function (e) {
      const btn = e.target.closest('[data-plan]');
      if (!btn) return;

      const plan = btn.dataset.plan;
      if (!plan) return;

      logger.info('Selected plan:', plan);

      if (plan === 'extrem') {
        window.location.href = '/opplaering?quiz=extrem';
      } else {
        window.location.href = '/app/settings?plan=' + encodeURIComponent(plan);
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // CALCULATOR: handled by separate calculator.js
  // ═══════════════════════════════════════════════════════════
  function initCalculator() {
    logger.info('Calculator mode (separate script handles logic)');
  }

  onReady(function () {
    if (isDashboard) initDashboard();
    if (isSettings) initSettings();
    if (isPricing) initPricing();
    if (isCalculator) initCalculator();

    logger.info('Site engine ready');
  });
})();
