// Update all open positions with current prices
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

// Supabase automatically injects these
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

interface Position {
  id: number
  symbol: string
  entry_price: number
  quantity: number
}

serve(async (req) => {
  try {
    console.log('🔄 Updating positions...')
    console.log('Environment check:', {
      hasSupabaseUrl: !!SUPABASE_URL,
      hasServiceKey: !!SUPABASE_SERVICE_KEY
    })

    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      },
      db: {
        schema: 'public'
      }
    })

    // Get all open positions
    const { data: positions, error: fetchError } = await supabase
      .from('positions')
      .select('id, symbol, entry_price, quantity')
      .eq('status', 'open')

    if (fetchError) {
      console.error('Fetch error:', fetchError)
      throw fetchError
    }

    if (!positions || positions.length === 0) {
      console.log('No open positions found')
      return new Response(
        JSON.stringify({ 
          success: true,
          message: 'No open positions',
          updated: 0
        }),
        { headers: { 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Found ${positions.length} open positions`)

    // Update each position
    const updates = await Promise.all(
      positions.map(async (pos: Position) => {
        // Get current price from CoinGecko (free API)
        const symbol = pos.symbol.toLowerCase()
        const response = await fetch(
          `https://api.coingecko.com/api/v3/simple/price?ids=${symbol}&vs_currencies=usd`
        )
        const priceData = await response.json()
        const currentPrice = priceData[symbol]?.usd

        if (!currentPrice) {
          console.error(`Failed to get price for ${pos.symbol}`)
          return null
        }

        const pnlUsd = (currentPrice - pos.entry_price) * pos.quantity
        const pnlPercent = ((currentPrice - pos.entry_price) / pos.entry_price) * 100

        // Update position
        const { error: updateError } = await supabase
          .from('positions')
          .update({
            current_price: currentPrice,
            pnl_usd: pnlUsd,
            pnl_percent: pnlPercent,
            updated_at: new Date().toISOString()
          })
          .eq('id', pos.id)

        if (updateError) {
          console.error(`Update error for position ${pos.id}:`, updateError)
          throw updateError
        }

        console.log(`✅ Updated ${pos.symbol}: PnL $${pnlUsd.toFixed(2)}`)
        return { id: pos.id, symbol: pos.symbol, pnl_usd: pnlUsd }
      })
    )

    const successCount = updates.filter(u => u !== null).length
    console.log(`✅ Successfully updated ${successCount} positions`)

    return new Response(
      JSON.stringify({
        success: true,
        updated: successCount,
        positions: updates.filter(u => u !== null)
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
