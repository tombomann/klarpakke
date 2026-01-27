// Klarpakke Site Engine v2.0
// Master UI script for all Webflow pages
// Handles: Landing, Dashboard, Settings, Pricing, Calculator

(function() {
  'use strict';

  const SUPABASE_URL = 'https://swfyuwkptusceiouqlks.supabase.co';
  const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN3Znl1d2twdHVzY2Vpb3VxbGtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzU1ODQ3OTksImV4cCI6MjA1MTE2MDc5OX0.C8-YqV3mQpxWqkX7oqD1k7iYqY6jz4Jxqq1z_1z1z1z';

  console.log('[Klarpakke] Site engine v2.0 loaded');

  // Detect current page
  const path = window.location.pathname;
  const isDashboard = path.includes('/dashboard');
  const isSettings = path.includes('/settings');
  const isPricing = path.includes('/pricing');
  const isCalculator = path.includes('/kalkulator');

  // ═══════════════════════════════════════════════════════════
  // DASHBOARD: Signal Approval
  // ═══════════════════════════════════════════════════════════
  if (isDashboard) {
    console.log('[Klarpakke] Dashboard mode');

    // Attach event listeners to approve/reject buttons
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
      .then(res => res.json())
      .then(data => {
        console.log('[Klarpakke] Success:', data);
        // Update UI (change button state, show toast, etc.)
        btn.textContent = action === 'approve' ? '✅ Approved' : '❌ Rejected';
        btn.disabled = true;
      })
      .catch(err => {
        console.error('[Klarpakke] Error:', err);
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
