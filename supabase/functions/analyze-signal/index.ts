import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

serve(async (req) => {
  const supabaseClient = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // Fetch pending signals
  const { data: signals, error } = await supabaseClient
    .from('aisignal')
    .select('*')
    .eq('status', 'pending')
    .order('created_at', { ascending: false })
    .limit(5)

  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 500,
      headers: { 'Content-Type': 'application/json' }
    })
  }

  // Analyze each signal
  const results = []
  for (const signal of signals) {
    const risk = Math.abs(signal.entry_price - signal.stop_loss)
    const reward = Math.abs(signal.take_profit - signal.entry_price)
    const rrRatio = reward / risk

    let decision = 'pending'
    let reasoning = ''

    if (rrRatio >= 2.0 && signal.confidence >= 0.75) {
      decision = 'approved'
      reasoning = `Strong R:R ${rrRatio.toFixed(2)}, high confidence`
      
      await supabaseClient
        .from('aisignal')
        .update({
          status: 'approved',
          approved_by: 'edge_function',
          reasoning
        })
        .eq('id', signal.id)
    }

    results.push({ signal_id: signal.id, decision, reasoning })
  }

  return new Response(JSON.stringify({ analyzed: results.length, results }), {
    headers: { 'Content-Type': 'application/json' }
  })
})
