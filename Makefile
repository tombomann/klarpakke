.PHONY: ai-test ai-health stripe-seed-usd stripe-verify-usd

ai-test:
    @[ -n "$$PPLX_API_KEY" ] || (echo "PPLX_API_KEY not set"; exit 1)
    curl -s -X POST https://api.perplexity.ai/chat/completions \
     -H "Authorization: Bearer $$PPLX_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"sonar-pro","messages":[{"role":"user","content":"Hei, gi en kort status for BTC-markedet."}], "max_tokens":200}' \
     | jq -e '.choices[0].message.content' >/dev/null

ai-health:
    bash scripts/perplexity_healthcheck.sh

stripe-seed-usd:
    bash scripts/stripe_seed_usd.sh

stripe-verify-usd:
    bash scripts/stripe_verify_usd.sh
