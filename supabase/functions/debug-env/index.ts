// Debug Edge Function - Check environment variables
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

serve(async (req) => {
  const envVars = {
    SUPABASE_URL: Deno.env.get('SUPABASE_URL'),
    SUPABASE_SERVICE_ROLE_KEY: Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ? 'SET (hidden)' : 'NOT SET',
    SUPABASE_ANON_KEY: Deno.env.get('SUPABASE_ANON_KEY') ? 'SET (hidden)' : 'NOT SET',
    PERPLEXITY_API_KEY: Deno.env.get('PERPLEXITY_API_KEY') ? 'SET (hidden)' : 'NOT SET',
    
    // Check all Supabase-related env vars
    allSupabaseVars: Object.keys(Deno.env.toObject())
      .filter(key => key.includes('SUPABASE'))
      .map(key => ({ key, hasValue: !!Deno.env.get(key) }))
  }

  console.log('Environment check:', envVars)

  return new Response(
    JSON.stringify(envVars, null, 2),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
