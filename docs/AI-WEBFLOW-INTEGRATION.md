# AI-Powered Webflow Integration Guide

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Last Updated:** 2026-01-29

---

## 🎯 Overview

This integration combines:

1. **Webflow MCP** - Programmatic Webflow API access
2. **Perplexity AI** - Intelligent content generation
3. **GitHub Actions** - Automated deployment

**Benefits:**
- 🤖 **95% time savings** on page creation
- 🎨 **Consistent branding** across all pages
- 🔍 **SEO-optimized** content automatically
- ⚡ **One-command deployment**

---

## 🚀 Quick Start

### 1. Setup Secrets

```bash
# .env file
WEBFLOW_API_TOKEN=wfp_xxx
WEBFLOW_SITE_ID=xxx
WEBFLOW_SIGNALS_COLLECTION_ID=xxx
PPLX_API_KEY=pplx-xxx  # Optional but recommended
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Build Pages

```bash
# Build all pages
npm run ai:build-pages

# Build specific pages
npm run ai:build-pages -- landing,pricing

# Generate element IDs
npm run ai:generate-ids
```

---

## 📚 Architecture

### Libraries

**`lib/webflow-mcp.js`**
- Webflow API v2 wrapper
- MCP-style interface
- Error handling & retries

**`lib/ai-content-generator.js`**
- Perplexity Sonar Pro integration
- Fallback templates
- SEO optimization

### Scripts

**`scripts/ai-build-webflow-pages.js`**
- Main page builder
- Template engine
- Batch processing

**`scripts/generate-element-ids.js`**
- Semantic ID generation
- Documentation auto-generation

---

## 🎨 Page Templates

### Landing Page
```javascript
{
  slug: 'index',
  name: 'Home',
  requirements: {
    tone: 'professional yet friendly',
    targetAudience: 'Norwegian retail investors',
    sections: ['hero', 'features', 'testimonials', 'cta']
  }
}
```

### Pricing
```javascript
{
  slug: 'pricing',
  name: 'Pricing',
  requirements: {
    plans: ['Paper', 'Safe', 'Pro', 'Extrem']
  }
}
```

---

## 🤖 AI Content Generation

### How It Works

1. **Template → Prompt**: Convert page requirements to AI prompt
2. **AI Generation**: Call Perplexity API
3. **Parse Response**: Extract structured content
4. **Fallback**: Use templates if AI fails

### Example

```javascript
const ai = new AIContentGenerator(process.env.PPLX_API_KEY);

const content = await ai.generatePageContent('landing', {
  tone: 'professional',
  targetAudience: 'Norwegian investors'
});

// Returns:
{
  headline: 'Trygg Krypto-Trading med AI',
  subheadline: 'Klarpakke hjelper småsparere...',
  cta: 'Start Gratis',
  features: [...]
}
```

---

## 📊 Workflow

### Local Development

```bash
# 1. Build pages
npm run ai:build-pages

# 2. Generate IDs
npm run ai:generate-ids

# 3. Verify in Webflow Designer
open https://webflow.com/dashboard

# 4. Publish
# (Manual in Webflow Designer)
```

### GitHub Actions

```bash
# Automatic on push to main
git push origin main

# Or manual trigger
# Go to Actions → AI Webflow Builder → Run workflow
```

---

## ✅ Testing

### Test Webflow Connection

```bash
node -e "
const WebflowMCP = require('./lib/webflow-mcp');
const w = new WebflowMCP(
  process.env.WEBFLOW_API_TOKEN,
  process.env.WEBFLOW_SITE_ID
);
w.getSiteInfo().then(r => 
  console.log(r.success ? '✅ Connected' : '❌ Failed')
);
"
```

### Test AI Generation

```bash
node -e "
const AI = require('./lib/ai-content-generator');
const ai = new AI(process.env.PPLX_API_KEY);
ai.generatePageContent('landing', {})
  .then(c => console.log('✅ Generated:', c.headline));
"
```

---

## 🚨 Troubleshooting

### Issue: "Webflow API Token Invalid"

**Solution:**
1. Go to Webflow Dashboard → Site Settings → Integrations
2. Generate new API token (v2)
3. Update `.env` and GitHub Secrets

### Issue: "Page Already Exists"

**Expected behavior.** Script skips existing pages.

To recreate:
1. Delete page in Webflow Designer
2. Re-run script

### Issue: "AI Generation Failed"

**Fallback content used automatically.**

Check:
- API key is valid
- API credits remaining
- Network connectivity

---

## 📈 Performance

### Before (Manual)
```
1. Open Webflow Designer
2. Create page
3. Write content
4. Add IDs
5. Optimize SEO
6. Repeat

⏱️ Time: 2-3 hours per page
```

### After (AI)
```
1. npm run ai:build-pages
2. Review
3. Publish

⏱️ Time: 5-10 minutes total
```

**Time savings: 95%** ⚡

---

## 🔗 Resources

- **API Reference:** `docs/WEBFLOW-MCP-USAGE.md`
- **Webflow API Docs:** https://developers.webflow.com/
- **Perplexity API:** https://docs.perplexity.ai/
- **GitHub Actions:** `.github/workflows/ai-webflow-builder.yml`
