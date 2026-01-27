import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';

// Embedded UI script (no external file dependency)
const UI_SCRIPT = `// Klarpakke Webflow UI Script
// Handles APPROVE/REJECT actions via data-kp-action + data-signal-id

(function() {
  'use strict';

  const SUPABASE_URL = 'https://swfyuwkptusceiouqlks.supabase.co';
  const APPROVE_ENDPOINT = \`\${SUPABASE_URL}/functions/v1/approve-signal\`;

  // Event delegation: listen on document for clicks on [data-kp-action]
  document.addEventListener('click', async (e) => {
    const btn = e.target.closest('[data-kp-action]');
    if (!btn) return;

    const action = btn.getAttribute('data-kp-action'); // APPROVE | REJECT
    const signalId = btn.getAttribute('data-signal-id');

    if (!signalId) {
      console.error('[Klarpakke] Missing data-signal-id on button');
      return;
    }

    if (!['APPROVE', 'REJECT'].includes(action)) {
      console.error('[Klarpakke] Invalid action:', action);
      return;
    }

    // Disable button + show loading
    btn.disabled = true;
    const originalText = btn.textContent;
    btn.textContent = action === 'APPROVE' ? 'Approving...' : 'Rejecting...';

    try {
      const resp = await fetch(APPROVE_ENDPOINT, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          signal_id: signalId,
          action: action.toLowerCase() // approve | reject
        })
      });

      if (!resp.ok) {
        const err = await resp.json();
        throw new Error(err.error || 'Request failed');
      }

      const result = await resp.json();
      console.log('[Klarpakke] Success:', result);

      // Update UI (find status element via data-kp-status-for)
      const statusEl = document.querySelector(\`[data-kp-status-for="\${signalId}"]\`);
      if (statusEl) {
        statusEl.textContent = action === 'APPROVE' ? 'Approved ✅' : 'Rejected ❌';
        statusEl.style.color = action === 'APPROVE' ? '#10b981' : '#ef4444';
      }

      // Hide or fade out the card (optional)
      const card = btn.closest('[data-signal-card]');
      if (card) {
        card.style.opacity = '0.5';
      }

      btn.textContent = action === 'APPROVE' ? 'Approved ✅' : 'Rejected ❌';

    } catch (error) {
      console.error('[Klarpakke] Error:', error);
      alert(\`Failed to \${action.toLowerCase()}: \${error.message}\`);
      btn.disabled = false;
      btn.textContent = originalText;
    }
  });

  console.log('[Klarpakke] UI script loaded. Listening for data-kp-action clicks.');
})();`;

serve(async (req) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: corsHeaders,
      status: 204,
    });
  }

  // Return JS script (public, no auth required)
  if (req.method === 'GET') {
    return new Response(UI_SCRIPT, {
      headers: {
        ...corsHeaders,
        'Content-Type': 'application/javascript; charset=utf-8',
        'Cache-Control': 'public, max-age=300',
      },
      status: 200,
    });
  }

  return new Response('Method not allowed', { status: 405 });
});
