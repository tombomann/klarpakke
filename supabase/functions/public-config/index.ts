import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { corsHeaders } from '../_shared/cors.ts';

// Public, cacheable config endpoint for Webflow.
// Purpose: avoid embedding keys/values in Webflow custom code.
// Note: Returning the anon key is acceptable (it's publishable); NEVER return service role.

function json(data: unknown, status = 200, extraHeaders: Record<string, string> = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'public, max-age=300',
      ...extraHeaders,
    },
  });
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { status: 204, headers: corsHeaders });
  }

  if (req.method !== 'GET') {
    return json({ error: 'Method not allowed' }, 405);
  }

  const supabaseUrl = Deno.env.get('SUPABASE_URL') || '';
  const supabaseAnonKey = Deno.env.get('SUPABASE_ANON_KEY') || '';
  const assetBase = Deno.env.get('KLARPAKKE_ASSET_BASE') || 'https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web';
  const debug = (Deno.env.get('KLARPAKKE_DEBUG') || '').toLowerCase();

  // Minimal validation
  if (!supabaseUrl || !supabaseAnonKey) {
    return json(
      {
        error: 'Missing required config on server',
        missing: {
          SUPABASE_URL: !supabaseUrl,
          SUPABASE_ANON_KEY: !supabaseAnonKey,
        },
      },
      500,
    );
  }

  // If clients send If-None-Match, we can respond 304.
  // Keep it simple: ETag is derived from a short hash-like string.
  const etag = `W/"kp-${supabaseUrl.length}-${supabaseAnonKey.length}-${assetBase.length}"`;
  const inm = req.headers.get('if-none-match');
  if (inm && inm === etag) {
    return new Response(null, { status: 304, headers: { ...corsHeaders, ETag: etag } });
  }

  return json(
    {
      supabaseUrl,
      supabaseAnonKey,
      assetBase,
      debug: debug === '1' || debug === 'true',
      version: 'public-config-v1',
    },
    200,
    { ETag: etag },
  );
});
