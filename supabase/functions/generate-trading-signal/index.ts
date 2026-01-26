// Klarpakke Trading Signal Generator
// Supabase Edge Function - Runs serverless
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const PERPLEXITY_API_KEY = Deno.env.get('PERPLEXITY_API_KEY')!
// Supabase automatically injects these - no secrets needed
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface TradingSignal {
  symbol: string
  direction: 'BUY' | 'SELL'
  confidence: number
  reasoning: string
}

serve(async (req) => {
  try {
    console.log('🤖 Generating trading signal...')
    console.log('Environment check:', {
      hasPerplexityKey: !!PERPLEXITY_API_KEY,
      hasSupabaseUrl: !!SUPABASE_URL,
      hasServiceKey: !!SUPABASE_SERVICE_KEY
    })

    // 1. Call Perplexity AI
    const perplexityResponse = await fetch('https://api.perplexity.ai/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${PERPLEXITY_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'sonar-pro',
        messages: [
          {
            role: 'system',
            content: 'You are a crypto trading analyst. Analyze BTC/ETH and provide ONE actionable signal. Return ONLY valid JSON: {"symbol": "BTC", "direction": "BUY", "confidence": 0.75, "reasoning": "your analysis"}'
          },
          {
            role: 'user',
            content: 'Analyze current crypto market. Provide trading signal for highest conviction play. Consider: price action, volume, sentiment, macro. Return ONLY the JSON object.'
          }
        ],
        temperature: 0.3,
        max_tokens: 500
      })
    })

    if (!perplexityResponse.ok) {
      throw new Error(`Perplexity API error: ${perplexityResponse.status}`)
    }

    const perplexityData = await perplexityResponse.json()
    const content = perplexityData.choices[0].message.content
    
    // Parse JSON from AI response
    let signal: TradingSignal
    try {
      signal = JSON.parse(content)
    } catch (e) {
      // If AI didn't return pure JSON, try to extract it
      const jsonMatch = content.match(/\{[^}]+\}/)
      if (!jsonMatch) throw new Error('Failed to parse AI response')
      signal = JSON.parse(jsonMatch[0])
    }

    console.log('📊 Signal generated:', signal)

    // 2. Insert to Supabase
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      },
      db: {
        schema: 'public'
      }
    })
    
    const { data: insertedSignal, error: insertError } = await supabase
      .from('signals')
      .insert({
        symbol: signal.symbol,
        direction: signal.direction,
        confidence: signal.confidence,
        reason: signal.reasoning,
        ai_model: 'perplexity-sonar-pro',
        status: 'pending'
      })
      .select()
      .single()

    if (insertError) {
      console.error('Insert error:', insertError)
      throw insertError
    }

    console.log('✅ Signal inserted:', insertedSignal.id)

    // 3. Check risk meter
    const { data: riskMeter, error: riskError } = await supabase
      .from('daily_risk_meter')
      .select('total_risk_usd')
      .eq('date', new Date().toISOString().split('T')[0])
      .single()

    if (riskError && riskError.code !== 'PGRST116') { // PGRST116 = not found is OK
      console.error('Risk meter error:', riskError)
    }

    const currentRisk = riskMeter?.total_risk_usd || 0
    console.log('📈 Current risk:', currentRisk)

    // 4. Auto-approve if risk < $4000
    if (currentRisk < 4000) {
      const { error: updateError } = await supabase
        .from('signals')
        .update({ status: 'approved' })
        .eq('id', insertedSignal.id)

      if (updateError) throw updateError
      console.log('✅ Signal auto-approved')
    } else {
      console.log('⚠️ Risk limit exceeded, awaiting manual approval')
    }

    return new Response(
      JSON.stringify({
        success: true,
        signal: insertedSignal,
        auto_approved: currentRisk < 4000
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('❌ Error:', error)
    return new Response(
      JSON.stringify({ 
        error: error.message,
        stack: error.stack 
      }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
