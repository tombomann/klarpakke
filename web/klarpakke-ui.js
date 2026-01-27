// Klarpakke Webflow UI Script (Plan A++: Full Automation)
// Handles: Fetching signals, Rendering cards, Approve/Reject actions
// Deploy: Paste this into Webflow Custom Code "Before </body> tag"

(function() {
  'use strict';

  const SUPABASE_URL = 'https://swfyuwkptusceiouqlks.supabase.co';
  const SERVE_ENDPOINT = `${SUPABASE_URL}/functions/v1/serve-signals`;
  const APPROVE_ENDPOINT = `${SUPABASE_URL}/functions/v1/approve-signal`;

  // --- STYLES (Injected dynamically) ---
  const styles = `
    #kp-signal-container {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
      gap: 24px;
      padding: 24px 0;
      width: 100%;
    }
    .kp-card {
      background: white;
      border-radius: 12px;
      padding: 24px;
      box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
      transition: all 0.2s ease;
      border: 1px solid #e5e7eb;
      display: flex;
      flex-direction: column;
    }
    .kp-card:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
    }
    .kp-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 16px;
    }
    .kp-symbol {
      font-size: 20px;
      font-weight: 700;
      color: #111827;
    }
    .kp-badge {
      padding: 4px 12px;
      border-radius: 9999px;
      font-size: 14px;
      font-weight: 600;
      color: white;
    }
    .kp-badge.high { background: #10b981; }
    .kp-badge.mid { background: #f59e0b; }
    .kp-badge.low { background: #ef4444; }
    
    .kp-meta {
      font-size: 14px;
      color: #6b7280;
      margin-bottom: 12px;
      font-style: italic;
    }
    .kp-reason {
      font-size: 15px;
      color: #374151;
      line-height: 1.5;
      margin-bottom: 24px;
      flex-grow: 1;
    }
    .kp-actions {
      display: flex;
      gap: 12px;
      margin-top: auto;
    }
    .kp-btn {
      flex: 1;
      padding: 10px 16px;
      border-radius: 6px;
      font-weight: 600;
      cursor: pointer;
      border: none;
      transition: background 0.2s;
      color: white;
      text-align: center;
    }
    .kp-btn-approve { background-color: #10b981; }
    .kp-btn-approve:hover { background-color: #059669; }
    .kp-btn-reject { background-color: #ef4444; }
    .kp-btn-reject:hover { background-color: #dc2626; }
    .kp-btn:disabled { opacity: 0.6; cursor: not-allowed; }
    
    /* Loading/Empty states */
    #kp-loading { text-align: center; padding: 40px; color: #6b7280; }
    #kp-error { color: #ef4444; text-align: center; padding: 20px; }
  `;

  // Inject CSS
  const styleSheet = document.createElement("style");
  styleSheet.innerText = styles;
  document.head.appendChild(styleSheet);

  // --- MAIN LOGIC ---

  async function fetchAndRender() {
    // Find or create container
    let container = document.getElementById('kp-signal-container');
    if (!container) {
      // Look for a placeholder div from Webflow, or create one
      // If user created a div with ID 'signal-container' in Webflow, use it.
      // Otherwise, append to main or body.
      const parent = document.querySelector('main') || document.body;
      
      // Create a wrapper section if missing
      const section = document.createElement('div');
      section.style.maxWidth = '1200px';
      section.style.margin = '0 auto';
      section.style.padding = '20px';
      
      const title = document.createElement('h2');
      title.textContent = 'Live Trading Signals (Auto-Rendered)';
      title.style.textAlign = 'center';
      title.style.marginBottom = '20px';
      
      container = document.createElement('div');
      container.id = 'kp-signal-container';
      
      section.appendChild(title);
      section.appendChild(container);
      parent.appendChild(section);
    }

    container.innerHTML = '<div id="kp-loading">Loading signals...</div>';

    try {
      const resp = await fetch(SERVE_ENDPOINT);
      if (!resp.ok) throw new Error(`API Error: ${resp.status}`);
      
      const data = await resp.json();
      const signals = data.signals || [];

      if (signals.length === 0) {
        container.innerHTML = '<div id="kp-loading">No pending signals found.</div>';
        return;
      }

      container.innerHTML = ''; // Clear loading

      signals.forEach(sig => {
        const card = createCard(sig);
        container.appendChild(card);
      });

    } catch (err) {
      console.error('[Klarpakke] Fetch error:', err);
      container.innerHTML = `<div id="kp-error">Failed to load signals. check console.</div>`;
    }
  }

  function createCard(sig) {
    const el = document.createElement('div');
    el.className = 'kp-card';
    el.setAttribute('data-signal-id', sig.id);

    // Confidence logic
    const conf = sig.confidence || 0;
    const confPercent = Math.round(conf * 100);
    let badgeClass = 'low';
    if (conf >= 0.8) badgeClass = 'high';
    else if (conf >= 0.7) badgeClass = 'mid';

    el.innerHTML = `
      <div class="kp-header">
        <div class="kp-symbol">${sig.symbol} &rarr; ${sig.direction}</div>
        <div class="kp-badge ${badgeClass}">${confPercent}%</div>
      </div>
      <div class="kp-meta">Status: ${sig.status} &bull; ${new Date(sig.created_at).toLocaleTimeString()}</div>
      <div class="kp-reason">${sig.reason || 'No analysis provided.'}</div>
      <div class="kp-actions">
        <button class="kp-btn kp-btn-approve" data-kp-action="APPROVE" data-id="${sig.id}">✓ Godkjenn</button>
        <button class="kp-btn kp-btn-reject" data-kp-action="REJECT" data-id="${sig.id}">✗ Avvis</button>
      </div>
    `;
    return el;
  }

  // Action Handler
  document.addEventListener('click', async (e) => {
    if (!e.target.matches('[data-kp-action]')) return;
    
    const btn = e.target;
    const action = btn.getAttribute('data-kp-action');
    const signalId = btn.getAttribute('data-id');
    
    if (!signalId) return;

    // UI Optimistic Update
    btn.disabled = true;
    const originalText = btn.textContent;
    btn.textContent = '...';
    
    try {
      const resp = await fetch(APPROVE_ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ signal_id: signalId, action: action.toLowerCase() })
      });

      if (!resp.ok) throw new Error('Action failed');

      // Success UI
      const card = btn.closest('.kp-card');
      card.style.opacity = '0.5';
      card.style.pointerEvents = 'none';
      
      // Update status text inside card
      const statusDiv = card.querySelector('.kp-meta');
      if (statusDiv) statusDiv.innerHTML = `<span style="color:${action === 'APPROVE' ? '#10b981' : '#ef4444'}"><b>${action}ED ✅</b></span>`;

    } catch (err) {
      alert(`Error: ${err.message}`);
      btn.disabled = false;
      btn.textContent = originalText;
    }
  });

  // Init
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', fetchAndRender);
  } else {
    fetchAndRender();
  }

  console.log('[Klarpakke] Auto-render script loaded (Plan A++)');
})();
