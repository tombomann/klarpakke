// Klarpakke Site Engine v2.4
// Webflow master script (landing + app)
// Updates: Public-config fetch + automatic Binance referral wiring

(function () {
  'use strict';

  // 1. Prevent double-execution
  if (window.__KLARPAKKE_SITE_ENGINE__) return;
  window.__KLARPAKKE_SITE_ENGINE__ = true;

  const DEFAULTS = {
    debug: false,
    fetchTimeoutMs: 15000,
  };

  // 2. Configuration & Utilities
  function getMeta(name) {
    const el = document.querySelector(`meta[name="${name}"]`);
    return el ? el.getAttribute('content') : null;
  }

  function getConfig() {
    const fromWindow = window.KLARPAKKE_CONFIG || window.klarpakkeConfig || {};
    // Prioritize window config (injected by loader), then meta/body
    const fromMeta = {
      supabaseUrl: getMeta('klarpakke:supabase-url'),
      supabaseAnonKey: getMeta('klarpakke:supabase-anon-key'),
      debug: getMeta('klarpakke:debug'),
    };

    // Merge: Defaults -> Body/Meta -> Window (Loader)
    const cfg = Object.assign({}, DEFAULTS, fromMeta, fromWindow);

    // Boolean normalization
    if (typeof cfg.debug === 'string') cfg.debug = cfg.debug === '1' || cfg.debug === 'true';

    // Normalize URL (strip trailing slash)
    if (cfg.supabaseUrl) cfg.supabaseUrl = String(cfg.supabaseUrl).replace(/\/$/, '');

    // LocalStorage override for testing
    try {
      if (localStorage.getItem('klarpakke_debug') === '1') cfg.debug = true;
    } catch (_) {}

    return cfg;
  }

  const config = getConfig();

  const logger = {
    debug: (...args) => (config.debug ? console.debug('[Klarpakke 🐞]', ...args) : undefined),
    info: (...args) => console.info('[Klarpakke ℹ️]', ...args),
    warn: (...args) => console.warn('[Klarpakke ⚠️]', ...args),
    error: (...args) => console.error('[Klarpakke ❌]', ...args),
  };

  function toast(message, type = 'info') {
    const el = document.getElementById('kp-toast');
    if (!el) {
      if (type === 'error' || config.debug) alert(`[${type.toUpperCase()}] ${message}`);
      return;
    }
    el.textContent = message;
    el.style.display = 'block';
    el.setAttribute('data-type', type);
    el.classList.remove('hidden'); // Webflow utility class support

    // Auto-hide
    setTimeout(() => {
      el.style.display = 'none';
      el.classList.add('hidden');
    }, type === 'error' ? 5000 : 3000);
  }

  function requireSupabaseConfig() {
    if (!config.supabaseUrl || !config.supabaseAnonKey) {
      logger.error('Missing Supabase config. Check webflow-loader injection.');
      if (config.debug) toast('Missing Supabase Config', 'error');
      return false;
    }
    return true;
  }

  async function fetchJson(endpoint, options = {}) {
    if (!requireSupabaseConfig()) throw new Error('Missing Config');

    const url = `${config.supabaseUrl}${endpoint}`;
    const method = options.method || 'GET';

    logger.debug(`Fetching: ${method} ${url}`);

    const ctrl = new AbortController();
    const t = setTimeout(() => ctrl.abort(), config.fetchTimeoutMs);

    try {
      const headers = {
        apikey: config.supabaseAnonKey,
        Authorization: `Bearer ${config.supabaseAnonKey}`,
        'Content-Type': 'application/json',
        ...options.headers,
      };

      const res = await fetch(url, { ...options, headers, signal: ctrl.signal });

      if (!res.ok) {
        const errorText = await res.text().catch(() => res.statusText);
        throw new Error(`API Error ${res.status}: ${errorText}`);
      }

      return await res.json();
    } catch (err) {
      logger.error('Fetch failed:', err);
      throw err;
    } finally {
      clearTimeout(t);
    }
  }

  // 2.1 Public config (from Supabase Edge Function)
  let _publicConfigPromise = null;

  function getPublicConfig() {
    if (_publicConfigPromise) return _publicConfigPromise;

    _publicConfigPromise = (async () => {
      try {
        // Served by: supabase/functions/public-config
        const pc = await fetchJson('/functions/v1/public-config');
        logger.debug('Public config loaded:', pc);
        return pc;
      } catch (err) {
        logger.warn('Could not load public-config (continuing):', err);
        return null;
      }
    })();

    return _publicConfigPromise;
  }

  function applyBinanceReferralUrl(url) {
    if (!url) return;

    // Webflow convention:
    // - Add attribute: data-kp-ref="binance" on <a> or <button>
    // - Optional: data-kp-ref-target="_blank"
    const els = document.querySelectorAll('[data-kp-ref="binance"], [data-kp-binance-referral]');
    if (!els.length) return;

    els.forEach((el) => {
      const target = el.getAttribute('data-kp-ref-target') || '_blank';

      if (el.tagName === 'A') {
        el.setAttribute('href', url);
        el.setAttribute('rel', 'noopener noreferrer');
        el.setAttribute('target', target);
        return;
      }

      // Buttons/divs: attach click handler
      el.addEventListener('click', (e) => {
        e.preventDefault();
        if (target === '_self') window.location.href = url;
        else window.open(url, target);
      });
    });

    logger.info(`Binance referral wiring applied to ${els.length} element(s)`);
  }

  async function initMarketing() {
    const pc = await getPublicConfig();
    const url = pc?.binance?.referralUrl;
    if (url) applyBinanceReferralUrl(url);
  }

  // 3. Robust Path Detection
  function getRoute() {
    const raw = window.location.pathname.replace(/\/+$/, '') || '/';
    return {
      raw,
      isDashboard: raw.endsWith('/dashboard'),
      isSettings: raw.endsWith('/settings'),
      isPricing: raw.endsWith('/pricing'),
      isCalculator: raw.endsWith('/kalkulator') || raw.endsWith('/calculator'),
    };
  }

  // 4. Element Safety Check
  function checkRequiredElements(ids) {
    const missing = ids.filter((id) => !document.getElementById(id));
    if (missing.length > 0) {
      logger.warn(`Missing required DOM elements on this route: ${missing.join(', ')}`);
      if (config.debug) toast(`Missing IDs: ${missing.join(', ')}`, 'error');
      return false;
    }
    return true;
  }

  // ═══════════════════════════════════════════════════════════
  // MODULES
  // ═══════════════════════════════════════════════════════════

  async function initDashboard() {
    logger.info('Initializing Dashboard...');
    if (!checkRequiredElements(['signals-container'])) return;

    const container = document.getElementById('signals-container');

    async function loadSignals() {
      container.innerHTML = '<div class="kp-loader">Laster signaler...</div>'; // Use CSS loader if available

      try {
        const signals = await fetchJson(
          '/rest/v1/signals?select=*&status=eq.pending&order=created_at.desc&limit=20',
        );

        if (!signals.length) {
          container.innerHTML = '<div class="kp-empty">Ingen nye signaler akkurat nå. ☕</div>';
          return;
        }

        container.innerHTML = signals.map(renderSignalCard).join('');
        logger.info(`Loaded ${signals.length} signals`);
      } catch (err) {
        container.innerHTML =
          '<div class="kp-error">Kunne ikke laste data. <button onclick="location.reload()">Prøv igjen</button></div>';
        toast('Feil ved lasting av signaler', 'error');
      }
    }

    function renderSignalCard(s) {
      const conf = s.confidence ? Math.round(s.confidence * 100) : 0;
      return `
        <div class="signal-card" id="signal-${s.id}">
          <div class="signal-header">
            <h3>${s.symbol} <span class="badge ${s.direction.toLowerCase()}">${s.direction}</span></h3>
            <span class="confidence" title="AI Confidence">${conf}%</span>
          </div>
          <p>${s.reason}</p>
          <div class="actions">
            <button class="btn-approve" data-action="APPROVE" data-id="${s.id}">Approve</button>
            <button class="btn-reject" data-action="REJECT" data-id="${s.id}">Reject</button>
          </div>
        </div>
      `;
    }

    // Event Delegation (Scoped to container)
    container.addEventListener('click', async (e) => {
      const btn = e.target.closest('button[data-action]');
      if (!btn) return;

      const { action, id } = btn.dataset;
      const card = document.getElementById(`signal-${id}`);

      // UI Optimistic Update
      const originalText = btn.innerText;
      btn.disabled = true;
      btn.innerText = '⏳...';

      try {
        await fetchJson('/functions/v1/approve-signal', {
          method: 'POST',
          body: JSON.stringify({ signal_id: id, action }),
        });

        toast(`Signal ${action === 'APPROVE' ? 'godkjent' : 'avvist'}!`, 'success');

        // Remove card gracefully
        if (card) {
          card.style.opacity = '0.5';
          setTimeout(() => card.remove(), 500);
        }
      } catch (err) {
        btn.innerText = originalText;
        btn.disabled = false;
        toast(`Feil: ${err.message}`, 'error');
      }
    });

    loadSignals();
  }

  function initSettings() {
    logger.info('Initializing Settings...');
    if (!checkRequiredElements(['save-settings', 'plan-select'])) return;

    document.getElementById('save-settings').addEventListener('click', async () => {
      const plan = document.getElementById('plan-select').value;
      const compound = document.getElementById('compound-toggle')?.checked || false;

      // Todo: Replace 'demo-user' with actual auth user when Auth implemented
      try {
        await fetchJson('/functions/v1/update-user-settings', {
          method: 'POST',
          body: JSON.stringify({ user_id: 'demo-user', plan, compounding_enabled: compound }),
        });
        toast('Innstillinger lagret ✅', 'success');
      } catch (err) {
        // Fallback to local storage if offline/no-auth
        localStorage.setItem('kp_settings', JSON.stringify({ plan, compound }));
        toast('Lagret lokalt (frakoblet)', 'warning');
      }
    });
  }

  function initPricing() {
    logger.info('Initializing Pricing logic...');
    // Listen to all clicks, check for data-plan attribute
    document.body.addEventListener('click', (e) => {
      const target = e.target.closest('[data-plan]');
      if (!target) return;

      const plan = target.dataset.plan;
      if (plan === 'extrem') {
        location.href = '/opplaering?quiz=start';
      } else {
        location.href = `/app/settings?plan=${plan}`;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // INIT
  // ═══════════════════════════════════════════════════════════

  function boot() {
    const route = getRoute();
    logger.info(`Booting on route: ${route.raw}`);
    logger.debug('Config loaded:', config);

    // Global marketing wiring (safe no-op if missing)
    initMarketing();

    if (route.isDashboard) initDashboard();
    else if (route.isSettings) initSettings();
    else if (route.isPricing) initPricing();

    // Calculator is handled by calculator.js (loaded in parallel)
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
})();
