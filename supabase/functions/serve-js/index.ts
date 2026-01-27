import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';

const UI_SCRIPT = await Deno.readTextFile('./klarpakke-ui.js');

serve(async (req) => {
  const headers = new Headers({
    'Content-Type': 'application/javascript',
    'Access-Control-Allow-Origin': '*',
    'Cache-Control': 'public, max-age=300', // 5 min cache
  });

  // CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response(null, { headers });
  }

  return new Response(UI_SCRIPT, { headers });
});
