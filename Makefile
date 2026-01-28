klarpakke-auto-fix:
	@echo "🚀 KLARPAKKE AUTO-FIX STARTED"
	gh workflow run webflow-builder.yml || echo "Using browser method"
	@echo "✅ Check: https://github.com/tombomann/klarpakke/actions"
	@echo "🧪 Test: https://klarpakke-c65071.webflow.io/app/dashboard"
