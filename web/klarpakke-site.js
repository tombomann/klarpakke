// Klarpakke Site Engine v2.1
// Master UI script for all Webflow pages
// Handles: Landing, Dashboard, Settings, Pricing, Calculator

(function() {
  'use strict';

  const SUPABASE_URL = 'https://swfyuwkptusceiouqlks.supabase.co';
  const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3Znl1d2twdHVzY2Vpb3VxbGtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkxODY4MDEsImV4cCI6MjA4NDc2MjgwMX0.ZSpSU8pkIDxY0DrBKRitID2Sx6OUUGy1D4bFMVSwWlk';

  console.log('[Klarpakke] Site engine v2.1 loaded');

  // Detect current page
  const path = window.location.pathname;
  const isDashboard = path.includes('/dashboard');
  const isSettings = path.includes('/settings');
  const isPricing = path.includes('/pricing');
  const isCalculator = path.includes('/kalkulator');

  // ═══════════════════════════════════════════════════════════
  // DASHBOARD: Fetch + Display Signals
  // ═══════════════════════════════════════════════════════════
  if (isDashboard) {
    console.log('[Klarpakke] Dashboard mode');

    // Load pending signals on page load
    loadSignals();

    function loadSignals() {
      const container = document.getElementById('signals-container');
      if (!container) {
        console.warn('[Klarpakke] No #signals-container found on page');
        return;
      }

      container.innerHTML = '<p>Loading signals...</p>';

      // Fetch pending signals from Supabase
      fetch(`${SUPABASE_URL}/rest/v1/signals?select=*&status=eq.pending&order=created_at.desc&limit=20`, {
        headers: {
          'apikey': SUPABASE_ANON_KEY,
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`
        }
      })
      .then(res => {
        if (!res.ok) throw new Error(`HTTP ${res.status}: ${res.statusText}`);
        return res.json();
      })
      .then(signals => {
        console.log('[Klarpakke] Loaded signals:', signals.length);

        if (signals.length === 0) {
          container.innerHTML = '<p>No pending signals. <a href="#">Seed demo data</a></p>';
          return;
        }

        // Render signals as cards
        container.innerHTML = signals.map(signal => `
          <div class="signal-card" data-signal-id="${signal.id}">
            <div class="signal-header">
              <span class="symbol">${signal.symbol}</span>
              <span class="direction ${signal.direction.toLowerCase()}">${signal.direction}</span>
            </div>
            <div class="signal-body">
              <p class="reason">${signal.reason}</p>
              <div class="meta">
                <span>Confidence: ${Math.round(signal.confidence * 100)}%</span>
                <span>Model: ${signal.ai_model}</span>
              </div>
            </div>
            <div class="signal-actions">
              <button class="btn-approve" data-action="approve" data-signal-id="${signal.id}">
                ✅ Approve
              </button>
              <button class="btn-reject" data-action="reject" data-signal-id="${signal.id}">
                ❌ Reject
              </button>
            </div>
          </div>
        `).join('');
      })
      .catch(err => {
        console.error('[Klarpakke] Error loading signals:', err);
        container.innerHTML = `<p style="color:red;">Failed to load signals: ${err.message}</p>`;
      });
    }

    // Handle approve/reject actions
    document.addEventListener('click', function(e) {
      const btn = e.target.closest('[data-action]');
      if (!btn) return;

      const action = btn.dataset.action;
      const signalId = btn.dataset.signalId;

      if (!signalId) {
        console.error('[Klarpakke] Missing signal_id on button');
        return;
      }

      console.log(`[Klarpakke] ${action} signal ${signalId}`);

      btn.disabled = true;
      btn.textContent = action === 'approve' ? 'Approving...' : 'Rejecting...';

      // Call Supabase Edge Function
      fetch(`${SUPABASE_URL}/functions/v1/approve-signal`, {
        method: 'POST',
        headers: {
          'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          signal_id: signalId,
          action: action.toUpperCase()
        })
      })
      .then(res => {
        if (!res.ok) throw new Error(`HTTP ${res.status}`);
        return res.json();
      })
      .then(data => {
        console.log('[Klarpakke] Success:', data);
        btn.textContent = action === 'approve' ? '✅ Approved' : '❌ Rejected';
        
        // Remove signal card from DOM after 2 seconds
        setTimeout(() => {
          const card = btn.closest('.signal-card');
          if (card) card.remove();
        }, 2000);
      })
      .catch(err => {
        console.error('[Klarpakke] Error:', err);
        btn.textContent = 'Failed';
        btn.disabled = false;
        alert('Failed to ' + action + ' signal. Check console.');
      });
    });
  }

  // ═══════════════════════════════════════════════════════════
  // SETTINGS: Plan Selection + Compounding Toggle
  // ═══════════════════════════════════════════════════════════
  if (isSettings) {
    console.log('[Klarpakke] Settings mode');

    // Handle "Save Settings" button
    const saveBtn = document.getElementById('save-settings');
    if (saveBtn) {
      saveBtn.addEventListener('click', function() {
        const plan = document.getElementById('plan-select')?.value;
        const compounding = document.getElementById('compound-toggle')?.checked;

        console.log('[Klarpakke] Save settings:', { plan, compounding });

        // Call backend to save user preferences
        fetch(`${SUPABASE_URL}/functions/v1/update-user-settings`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${SUPABASE_ANON_KEY}`,
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({
            user_id: 'demo-user',  // Replace with actual auth
            plan: plan,
            compounding_enabled: compounding
          })
        })
        .then(res => res.json())
        .then(data => {
          console.log('[Klarpakke] Settings saved:', data);
          alert('✅ Settings saved!');
        })
        .catch(err => {
          console.error('[Klarpakke] Error:', err);
          alert('Failed to save settings. Check console.');
        });
      });
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PRICING: Plan Selection (EXTREM requires quiz)
  // ═══════════════════════════════════════════════════════════
  if (isPricing) {
    console.log('[Klarpakke] Pricing mode');

    // Handle plan selection buttons
    document.addEventListener('click', function(e) {
      const btn = e.target.closest('[data-plan]');
      if (!btn) return;

      const plan = btn.dataset.plan;
      console.log('[Klarpakke] Selected plan:', plan);

      if (plan === 'extrem') {
        // Redirect to quiz
        window.location.href = '/opplaering?quiz=extrem';
      } else {
        // Redirect to checkout or settings
        window.location.href = '/app/settings?plan=' + plan;
      }
    });
  }

  // ═══════════════════════════════════════════════════════════
  // CALCULATOR: Compound Interest (handled by separate calculator.js)
  // ═══════════════════════════════════════════════════════════
  if (isCalculator) {
    console.log('[Klarpakke] Calculator mode (separate script handles logic)');
  }

  console.log('[Klarpakke] Site engine ready');
})();
