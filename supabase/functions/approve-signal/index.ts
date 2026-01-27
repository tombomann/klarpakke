import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0';

const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
);

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      headers: { 'Access-Control-Allow-Origin': '*', 'Access-Control-Allow-Methods': 'POST', 'Access-Control-Allow-Headers': 'Content-Type' },
    });
  }

  try {
    const { signal_id, action } = await req.json();

    if (!signal_id || !['approve', 'reject'].includes(action)) {
      return new Response(JSON.stringify({ error: 'Invalid signal_id or action' }), {
        status: 400,
        headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
      });
    }

    const newStatus = action === 'approve' ? 'approved' : 'rejected';

    const { data, error } = await supabase
      .from('signals')
      .update({ status: newStatus, updated_at: new Date().toISOString() })
      .eq('id', signal_id)
      .select()
      .single();

    if (error) throw error;

    return new Response(JSON.stringify({ success: true, signal: data }), {
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json', 'Access-Control-Allow-Origin': '*' },
    });
  }
});
