// Update all open positions with current prices
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

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
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

    // Get all open positions
    const { data: positions, error: fetchError } = await supabase
      .from('positions')
      .select('id, symbol, entry_price, quantity')
      .eq('status', 'open')

    if (fetchError) throw fetchError

    if (!positions || positions.length === 0) {
      return new Response(
        JSON.stringify({ message: 'No open positions' }),
        { headers: { 'Content-Type': 'application/json' } }
      )
    }

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

        if (updateError) throw updateError

        return { id: pos.id, symbol: pos.symbol, pnl_usd: pnlUsd }
      })
    )

    return new Response(
      JSON.stringify({
        success: true,
        updated: updates.filter(u => u !== null).length
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    console.error('Error:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { 'Content-Type': 'application/json' } }
    )
  }
})
