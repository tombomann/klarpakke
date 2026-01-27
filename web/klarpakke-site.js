// Klarpakke Full Site Engine (Auto-Generated)
// Handles: Landing Page (Home) & Dashboard (App)
// Deploy: Paste this into Webflow Custom Code "Before </body> tag" (Site-wide)

(function() {
  'use strict';

  const PATH = window.location.pathname;
  const SUPABASE_URL = 'https://swfyuwkptusceiouqlks.supabase.co';
  const SERVE_ENDPOINT = `${SUPABASE_URL}/functions/v1/serve-signals`;
  const APPROVE_ENDPOINT = `${SUPABASE_URL}/functions/v1/approve-signal`;

  // --- ROUTER ---
  if (PATH === '/' || PATH === '/index.html') {
    renderLandingPage();
  } else if (PATH.includes('/app/dashboard')) {
    renderDashboard();
  }

  // --- LANDING PAGE RENDERER ---
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

  // --- DASHBOARD RENDERER ---
  async function renderDashboard() {
    // Dashboard Styles
    const style = document.createElement('style');
    style.innerHTML = `
      #kp-signal-container { display: grid; grid-template-columns: repeat(auto-fill, minmax(300px, 1fr)); gap: 24px; padding: 24px 0; width: 100%; max-width: 1200px; margin: 0 auto; }
      .kp-card { background: white; border-radius: 12px; padding: 24px; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.1); border: 1px solid #e5e7eb; display: flex; flex-direction: column; }
      .kp-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; }
      .kp-symbol { font-size: 20px; font-weight: 700; color: #111827; }
      .kp-badge { padding: 4px 12px; border-radius: 9999px; font-size: 14px; font-weight: 600; color: white; }
      .kp-badge.high { background: #10b981; } .kp-badge.mid { background: #f59e0b; } .kp-badge.low { background: #ef4444; }
      .kp-meta { font-size: 14px; color: #6b7280; margin-bottom: 12px; }
      .kp-reason { font-size: 15px; color: #374151; line-height: 1.5; margin-bottom: 24px; flex-grow: 1; }
      .kp-actions { display: flex; gap: 12px; margin-top: auto; }
      .kp-btn { flex: 1; padding: 10px; border-radius: 6px; border: none; cursor: pointer; color: white; font-weight: 600; transition: opacity 0.2s; }
      .kp-btn-approve { background: #10b981; } .kp-btn-reject { background: #ef4444; }
    `;
    document.head.appendChild(style);

    // Ensure Container
    let container = document.getElementById('kp-signal-container');
    if (!container) {
      const main = document.querySelector('main') || document.body;
      main.innerHTML = ''; // Clear Webflow placeholder content
      
      const header = document.createElement('div');
      header.style.padding = '40px 20px';
      header.style.textAlign = 'center';
      header.innerHTML = '<h2 style="font-size:2rem; margin-bottom:10px;">Live Trading Signals</h2><p style="color:#666;">Sanntids feed fra Supabase Edge</p>';
      
      container = document.createElement('div');
      container.id = 'kp-signal-container';
      container.innerHTML = '<div style="text-align:center; padding:40px;">Laster signaler...</div>';
      
      main.appendChild(header);
      main.appendChild(container);
    }

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
        
        const card = document.createElement('div');
        card.className = 'kp-card';
        card.innerHTML = `
          <div class="kp-header">
            <div class="kp-symbol">${sig.symbol} &rarr; ${sig.direction}</div>
            <div class="kp-badge ${badgeClass}">${confPercent}%</div>
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

  // Global Action Handler
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

  console.log('[Klarpakke] Full Site Engine Loaded');
})();
