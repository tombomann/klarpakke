// Klarpakke Full Site Engine v2.0
// Handles: Landing, Dashboard, Settings (Binance/Paper), Pricing
// Deploy: Paste this into Webflow Custom Code "Before </body> tag" (Project Settings)

(function() {
  'use strict';

  const PATH = window.location.pathname;
  // Fjern trailing slash for enklere matching
  const CLEAN_PATH = PATH.replace(/\/$/, "");
  
  const SUPABASE_URL = 'https://swfyuwkptusceiouqlks.supabase.co';
  const SERVE_ENDPOINT = `${SUPABASE_URL}/functions/v1/serve-signals`;
  const APPROVE_ENDPOINT = `${SUPABASE_URL}/functions/v1/approve-signal`;

  // --- ROUTER ---
  // Sjekker hvilken side brukeren er på og kjører riktig funksjon
  if (CLEAN_PATH === '' || CLEAN_PATH === '/index.html') {
    renderLandingPage();
  } else if (CLEAN_PATH.includes('/app/dashboard')) {
    injectAppStyles();
    renderSidebar('dashboard'); // Markerer dashboard som aktiv
    renderDashboard();
  } else if (CLEAN_PATH.includes('/app/settings')) {
    injectAppStyles();
    renderSidebar('settings'); // Markerer settings som aktiv
    renderSettings();
  } else if (CLEAN_PATH.includes('/app/pricing')) {
    injectAppStyles();
    renderSidebar('pricing');
    renderPricing();
  }

  // --- SHARED APP STYLES (Dashboard, Settings, Pricing) ---
  function injectAppStyles() {
    if (document.getElementById('kp-app-styles')) return;
    const style = document.createElement('style');
    style.id = 'kp-app-styles';
    style.innerHTML = `
      body { background-color: #f3f4f6; color: #1f2937; font-family: -apple-system, sans-serif; }
      .kp-layout { display: flex; min-height: 100vh; }
      .kp-sidebar { width: 250px; background: white; border-right: 1px solid #e5e7eb; padding: 24px; display: flex; flex-direction: column; position: fixed; height: 100%; }
      .kp-main { flex: 1; padding: 40px; margin-left: 250px; max-width: 1200px; }
      .kp-brand { font-size: 1.5rem; font-weight: 800; margin-bottom: 40px; color: #111827; text-decoration: none; }
      .kp-nav-item { display: block; padding: 12px 16px; margin-bottom: 8px; border-radius: 8px; color: #4b5563; text-decoration: none; font-weight: 500; transition: all 0.2s; }
      .kp-nav-item:hover { background: #f9fafb; color: #111827; }
      .kp-nav-item.active { background: #ecfdf5; color: #059669; }
      
      /* Card Styles */
      .kp-card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; margin-bottom: 24px; }
      .kp-card-title { font-size: 1.25rem; font-weight: 700; margin-bottom: 16px; border-bottom: 1px solid #f3f4f6; padding-bottom: 12px; }
      
      /* Form Elements */
      .kp-form-group { margin-bottom: 20px; }
      .kp-label { display: block; font-size: 0.875rem; font-weight: 500; margin-bottom: 8px; color: #374151; }
      .kp-input { width: 100%; padding: 10px; border: 1px solid #d1d5db; border-radius: 6px; font-size: 1rem; }
      .kp-btn-primary { background: #10b981; color: white; padding: 10px 20px; border: none; border-radius: 6px; font-weight: 600; cursor: pointer; }
      .kp-btn-primary:hover { background: #059669; }
      
      /* Toggle Switch */
      .kp-toggle { position: relative; display: inline-block; width: 50px; height: 26px; }
      .kp-toggle input { opacity: 0; width: 0; height: 0; }
      .kp-slider { position: absolute; cursor: pointer; top: 0; left: 0; right: 0; bottom: 0; background-color: #ccc; transition: .4s; border-radius: 34px; }
      .kp-slider:before { position: absolute; content: ""; height: 20px; width: 20px; left: 3px; bottom: 3px; background-color: white; transition: .4s; border-radius: 50%; }
      input:checked + .kp-slider { background-color: #10b981; }
      input:checked + .kp-slider:before { transform: translateX(24px); }

      /* Pricing Grid */
      .kp-pricing-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }
      .kp-price-card { border: 1px solid #e5e7eb; border-radius: 12px; padding: 32px; text-align: center; background: white; position: relative; }
      .kp-price-card.featured { border: 2px solid #10b981; box-shadow: 0 10px 15px -3px rgba(16, 185, 129, 0.1); transform: scale(1.05); z-index: 10; }
      .kp-price-amount { font-size: 2.5rem; font-weight: 800; margin: 20px 0; color: #111827; }
    `;
    document.head.appendChild(style);
  }

  // --- SIDEBAR RENDERER ---
  function renderSidebar(activePage) {
    const existing = document.querySelector('.kp-sidebar');
    if (existing) return; // Ikke render på nytt hvis den finnes

    // Clear body and setup Layout
    document.body.innerHTML = '';
    const layout = document.createElement('div');
    layout.className = 'kp-layout';
    
    layout.innerHTML = `
      <nav class="kp-sidebar">
        <a href="/" class="kp-brand">Klarpakke</a>
        <a href="/app/dashboard" class="kp-nav-item ${activePage === 'dashboard' ? 'active' : ''}">📊 Dashboard</a>
        <a href="/app/settings" class="kp-nav-item ${activePage === 'settings' ? 'active' : ''}">⚙️ Innstillinger</a>
        <a href="/app/pricing" class="kp-nav-item ${activePage === 'pricing' ? 'active' : ''}">💎 Abonnement</a>
        <div style="margin-top: auto; padding-top: 20px; border-top: 1px solid #e5e7eb; font-size: 0.8rem; color: #9ca3af;">
          Logget inn som:<br><strong>demo@klarpakke.no</strong>
        </div>
      </nav>
      <main class="kp-main" id="kp-page-content">
        <!-- Page Content injected here -->
      </main>
    `;
    document.body.appendChild(layout);
  }

  // --- PAGE: SETTINGS (Binance & Paper) ---
  function renderSettings() {
    const container = document.getElementById('kp-page-content');
    container.innerHTML = `
      <h1 style="margin-bottom: 30px; font-size: 2rem; font-weight: 800;">Innstillinger</h1>
      
      <!-- PAPER TRADING -->
      <div class="kp-card">
        <div class="kp-card-title">🧪 Paper Trading (Testmodus)</div>
        <div style="display: flex; align-items: center; justify-content: space-between;">
          <p style="color: #6b7280; margin: 0; max-width: 600px;">
            Når aktiv, vil ingen ekte handler utføres. Alle signaler simuleres med virtuelle penger. 
            Perfekt for å teste strategien risikofritt.
          </p>
          <label class="kp-toggle">
            <input type="checkbox" checked onchange="console.log('Paper mode toggled')">
            <span class="kp-slider"></span>
          </label>
        </div>
      </div>

      <!-- EXCHANGE CONNECT -->
      <div class="kp-card">
        <div class="kp-card-title">🔗 Koble til Binance</div>
        <p style="color: #6b7280; margin-bottom: 20px;">
          Vi trenger API-nøkler med "Spot Trading" tillatelse. <strong>Ikke</strong> gi tillatelse til uttak (Withdrawals).
          Nøklene krypteres før de lagres i databasen.
        </p>
        <form onsubmit="event.preventDefault(); alert('Dette vil sende nøklene til save-exchange-keys funksjonen (kryptert).');">
          <div class="kp-form-group">
            <label class="kp-label">API Key</label>
            <input type="text" class="kp-input" placeholder="Lim inn din Binance API Key" required>
          </div>
          <div class="kp-form-group">
            <label class="kp-label">API Secret</label>
            <input type="password" class="kp-input" placeholder="Lim inn din Binance API Secret" required>
          </div>
          <button type="submit" class="kp-btn-primary">Lagre & Krypter</button>
        </form>
      </div>
    `;
  }

  // --- PAGE: PRICING ---
  function renderPricing() {
    const container = document.getElementById('kp-page-content');
    container.innerHTML = `
      <h1 style="margin-bottom: 10px; font-size: 2rem; font-weight: 800; text-align: center;">Velg din plan</h1>
      <p style="text-align: center; color: #6b7280; margin-bottom: 50px;">Skaler opp når du er klar.</p>
      
      <div class="kp-pricing-grid">
        <!-- FREE -->
        <div class="kp-price-card">
          <h3>Hobby</h3>
          <div class="kp-price-amount">kr 0</div>
          <p style="color: #6b7280; margin-bottom: 24px;">/mnd</p>
          <ul style="list-style: none; padding: 0; text-align: left; margin-bottom: 30px; line-height: 2;">
            <li>✅ Manuelle signaler</li>
            <li>✅ Paper Trading</li>
            <li>❌ Automatisk utførelse</li>
          </ul>
          <button class="kp-btn-primary" style="width: 100%; background: #e5e7eb; color: #374151;">Nåværende Plan</button>
        </div>

        <!-- STARTER -->
        <div class="kp-price-card featured">
          <div style="background: #10b981; color: white; padding: 4px 12px; border-radius: 99px; position: absolute; top: -12px; left: 50%; transform: translateX(-50%); font-size: 0.8rem; font-weight: 700;">MEST POPULÆR</div>
          <h3>Trader</h3>
          <div class="kp-price-amount">kr 499</div>
          <p style="color: #6b7280; margin-bottom: 24px;">/mnd</p>
          <ul style="list-style: none; padding: 0; text-align: left; margin-bottom: 30px; line-height: 2;">
            <li>✅ Alt i Hobby</li>
            <li>✅ <strong>Binance Automasjon</strong></li>
            <li>✅ Risikokalkulator</li>
            <li>✅ SMS Varsling</li>
          </ul>
          <button class="kp-btn-primary" style="width: 100%;" onclick="alert('Sender til Stripe Checkout...')">Velg Trader</button>
        </div>

        <!-- PRO -->
        <div class="kp-price-card">
          <h3>Whale</h3>
          <div class="kp-price-amount">kr 999</div>
          <p style="color: #6b7280; margin-bottom: 24px;">/mnd</p>
          <ul style="list-style: none; padding: 0; text-align: left; margin-bottom: 30px; line-height: 2;">
            <li>✅ Alt i Trader</li>
            <li>✅ <strong>Prioritert utførelse</strong></li>
            <li>✅ VIP Support</li>
            <li>✅ Custom Strategier</li>
          </ul>
          <button class="kp-btn-primary" style="width: 100%; background: #111827;" onclick="alert('Sender til Stripe Checkout...')">Velg Whale</button>
        </div>
      </div>
    `;
  }

  // --- PAGE: DASHBOARD (Existing Logic) ---
  async function renderDashboard() {
    const containerId = 'kp-signal-container';
    const content = document.getElementById('kp-page-content');
    
    // Setup Dashboard Container inside Main
    content.innerHTML = `
      <div style="display:flex; justify-content:space-between; align-items:center; margin-bottom:30px;">
        <h1 style="font-size: 2rem; font-weight: 800; margin:0;">Markedssignaler</h1>
        <div style="background:#ecfdf5; color:#059669; padding:8px 16px; border-radius:99px; font-weight:600; font-size:0.9rem;">🟢 System Online</div>
      </div>
      <div id="${containerId}">Laster signaler...</div>
    `;

    const container = document.getElementById(containerId);
    container.style.display = 'grid';
    container.style.gridTemplateColumns = 'repeat(auto-fill, minmax(300px, 1fr))';
    container.style.gap = '24px';

    // Fetch Logic
    try {
      const resp = await fetch(SERVE_ENDPOINT);
      if (!resp.ok) throw new Error('API Error');
      const data = await resp.json();
      const signals = data.signals || [];

      if (signals.length === 0) {
        container.innerHTML = '<div style="text-align:center;">Ingen nye signaler.</div>';
        return;
      }

      container.innerHTML = '';
      signals.forEach(sig => {
        const confPercent = Math.round((sig.confidence || 0) * 100);
        const badgeClass = confPercent >= 80 ? 'high' : confPercent >= 70 ? 'mid' : 'low';
        
        // Inline styles for cards (reusing style tag classes, but ensuring specific grid fit)
        const card = document.createElement('div');
        card.className = 'kp-card';
        card.innerHTML = `
          <div class="kp-header">
            <div class="kp-symbol">${sig.symbol} &rarr; ${sig.direction}</div>
            <div class="kp-badge ${badgeClass}" style="background: ${badgeClass === 'high' ? '#10b981' : badgeClass === 'mid' ? '#f59e0b' : '#ef4444'}; color:white; padding:4px 12px; border-radius:99px; font-weight:600;">${confPercent}%</div>
          </div>
          <div class="kp-meta">${new Date(sig.created_at).toLocaleTimeString()}</div>
          <div class="kp-reason">${sig.reason}</div>
          <div class="kp-actions">
            <button class="kp-btn kp-btn-approve" onclick="window.kpAction('${sig.id}','approve',this)">Godkjenn</button>
            <button class="kp-btn kp-btn-reject" onclick="window.kpAction('${sig.id}','reject',this)">Avvis</button>
          </div>
        `;
        container.appendChild(card);
      });
    } catch (e) {
      container.innerHTML = `<div style="color:red; text-align:center;">Feil: ${e.message}</div>`;
    }
  }
  
  // --- PAGE: LANDING (Existing Logic) ---
  function renderLandingPage() {
    // Override styles for Landing
    const style = document.createElement('style');
    style.innerHTML = `
      body { margin: 0; font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: #0f172a; color: #f8fafc; }
      .kp-hero { min-height: 90vh; display: flex; flex-direction: column; justify-content: center; align-items: center; text-align: center; padding: 20px; background: radial-gradient(circle at center, #1e293b 0%, #0f172a 100%); }
      .kp-h1 { font-size: 4rem; font-weight: 800; margin-bottom: 20px; letter-spacing: -0.02em; background: linear-gradient(to right, #fff, #94a3b8); -webkit-background-clip: text; -webkit-text-fill-color: transparent; }
      .kp-sub { font-size: 1.5rem; color: #94a3b8; max-width: 600px; margin-bottom: 40px; line-height: 1.6; }
      .kp-cta { background: #10b981; color: white; padding: 16px 32px; border-radius: 99px; font-weight: 600; font-size: 1.1rem; text-decoration: none; transition: transform 0.2s; display: inline-block; }
      .kp-cta:hover { transform: scale(1.05); background: #059669; }
      .kp-ticker { background: #1e293b; padding: 10px 20px; border-radius: 99px; border: 1px solid #334155; font-size: 0.9rem; color: #10b981; margin-bottom: 30px; display: inline-flex; align-items: center; gap: 10px; }
      .kp-dot { width: 8px; height: 8px; background: #10b981; border-radius: 50%; animation: pulse 2s infinite; }
      @keyframes pulse { 0% { opacity: 1; } 50% { opacity: 0.5; } 100% { opacity: 1; } }
      .kp-features { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 40px; max-width: 1200px; margin: 80px auto; padding: 20px; }
      .kp-feat-card { background: #1e293b; padding: 30px; border-radius: 16px; border: 1px solid #334155; }
      .kp-feat-title { font-size: 1.5rem; font-weight: 700; margin-bottom: 10px; color: white; }
      .kp-feat-desc { color: #94a3b8; line-height: 1.5; }
    `;
    document.head.appendChild(style);

    // Replace Body Content
    document.body.innerHTML = `
      <div class="kp-hero">
        <div class="kp-ticker"><div class="kp-dot"></div> System Online | Tracking: BTC, ETH, SOL, TSLA</div>
        <h1 class="kp-h1">Profitt gjennom kontroll.</h1>
        <p class="kp-sub">Automatisert risikoanalyse og handelssignaler for småsparere. Vi beskytter nedsiden så du kan nyte oppsiden.</p>
        <a href="/app/dashboard" class="kp-cta">Se Live Signaler &rarr;</a>
      </div>

      <div class="kp-features">
        <div class="kp-feat-card">
          <div class="kp-feat-title">🛡️ Risikostyring</div>
          <p class="kp-feat-desc">Vi går aldri "all in". Systemet beregner optimal posisjonsstørrelse basert på volatilitet (ATR) og din portefølje.</p>
        </div>
        <div class="kp-feat-card">
          <div class="kp-feat-title">🤖 AI-Drevet</div>
          <p class="kp-feat-desc">Perplexity Sonar Pro analyserer makro-nyheter og sentiment i sanntid før teknisk analyse bekrefter trenden.</p>
        </div>
        <div class="kp-feat-card">
          <div class="kp-feat-title">🔍 Etterprøvbart</div>
          <p class="kp-feat-desc">Ingen svarte bokser. Alle signaler logges åpent med begrunnelse, confidence-score og resultat.</p>
        </div>
      </div>
      
      <div style="text-align:center; padding: 40px; color: #64748b; font-size: 0.9rem;">
        &copy; 2026 Klarpakke. Bygget for norske småsparere.
      </div>
    `;
  }

  // Global Action Handler (Dashboard)
  window.kpAction = async (id, action, btn) => {
    btn.textContent = '...';
    btn.disabled = true;
    try {
      await fetch(APPROVE_ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ signal_id: id, action })
      });
      const card = btn.closest('.kp-card');
      card.style.opacity = '0.5';
      card.style.pointerEvents = 'none';
      btn.textContent = action === 'approve' ? 'Godkjent' : 'Avvist';
    } catch (e) {
      alert('Feil ved oppdatering');
      btn.textContent = 'Prøv igjen';
      btn.disabled = false;
    }
  };

  console.log('[Klarpakke] Full Site Engine Loaded (v2)');
})();
