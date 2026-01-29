# 🤖 AI-Powered Webflow Automation

**Status:** ✅ Production Ready  
**Integration:** Webflow MCP + Perplexity Pro  
**Automation Level:** Full Stack

---

## 🎉 Hva Er Dette?

Dette er en **komplett AI-drevet Webflow automatisering** som kombinerer:

1. **Webflow MCP Wrapper** - Programmatic access til Webflow API
2. **Perplexity Pro AI** - Innholdsgenerering og optimalisering
3. **GitHub Actions** - Automatisk deployment
4. **Smart Templates** - Ferdigkonfigurerte sidestrukturer

---

## 🚀 Quick Start

### 1. Setup Environment Variables

```bash
# .env
WEBFLOW_API_TOKEN=your_webflow_token
WEBFLOW_SITE_ID=your_site_id
PPLX_API_KEY=your_perplexity_key  # Optional but recommended
```

### 2. Run AI Page Builder

```bash
# Build all pages with AI-generated content
npm run ai:build-pages

# Generate element IDs
npm run ai:generate-ids

# Optimize for SEO
npm run ai:seo-optimize

# Or run all at once
npm run ai:webflow-full
```

### 3. Via GitHub Actions

**Manual Trigger:**
1. Go to **Actions** tab
2. Select **🤖 AI Webflow Page Builder**
3. Click **Run workflow**
4. Choose pages to build
5. Enable/disable AI content generation

---

## 📚 Webflow MCP API

### Library: `lib/webflow-mcp.js`

**Usage:**
```javascript
const WebflowMCP = require('./lib/webflow-mcp');

const webflow = new WebflowMCP(
  process.env.WEBFLOW_API_TOKEN,
  process.env.WEBFLOW_SITE_ID
);

// List all pages
const pages = await webflow.listPages();

// Create new page
const result = await webflow.createPage({
  slug: 'pricing',
  name: 'Pricing',
  title: 'Klarpakke - Priser'
});

// Get collection items
const items = await webflow.getCollectionItems('collection_id');

// Publish site
await webflow.publishSite();
```

**Available Methods:**
- `listPages()` - List all pages
- `getPage(slug)` - Get specific page
- `createPage(data)` - Create new page
- `updatePageMetadata(pageId, metadata)` - Update page
- `listCollections()` - List CMS collections
- `getCollectionItems(collectionId)` - Get items from collection
- `createCollectionItem(collectionId, fields)` - Create CMS item
- `publishSite(domains)` - Publish to production
- `getSiteInfo()` - Get site details

---

## 🤖 AI Content Generator

### Library: `lib/ai-content-generator.js`

**Usage:**
```javascript
const AIContentGenerator = require('./lib/ai-content-generator');

const ai = new AIContentGenerator(process.env.PPLX_API_KEY);

// Generate page content
const content = await ai.generatePageContent('landing', {
  tone: 'professional',
  targetAudience: 'Norwegian investors',
  sections: ['hero', 'features', 'cta']
});

// Generate element IDs
const ids = await ai.generateElementIDs({
  sections: ['hero', 'features'],
  components: ['cta-button']
});

// SEO optimization
const optimized = await ai.optimizeForSEO(
  content,
  ['krypto trading', 'AI investering']
);
```

**Features:**
- **Content Generation** - Headlines, copy, CTAs
- **Element ID Generation** - Semantic, Webflow-compliant IDs
- **SEO Optimization** - Meta tags, headers, keyword integration
- **Fallback Content** - Works without AI (uses templates)

---

## 📝 Page Templates

### Built-in Templates

#### 1. Landing Page
```javascript
{
  slug: 'index',
  name: 'Home',
  title: 'Klarpakke - Trygg Krypto-Trading',
  requirements: {
    tone: 'professional yet friendly',
    targetAudience: 'Norwegian retail investors',
    sections: ['hero', 'features', 'testimonials', 'cta']
  }
}
```

#### 2. Pricing Page
```javascript
{
  slug: 'pricing',
  name: 'Pricing',
  title: 'Klarpakke - Priser',
  requirements: {
    plans: ['Paper', 'Safe', 'Pro', 'Extrem'],
    emphasis: 'value and transparency'
  }
}
```

#### 3. Dashboard
```javascript
{
  slug: 'app/dashboard',
  name: 'Dashboard',
  requirements: {
    type: 'app',
    features: ['signals list', 'filters', 'real-time updates']
  }
}
```

#### 4. Calculator
```javascript
{
  slug: 'app/kalkulator',
  name: 'Kalkulator',
  requirements: {
    type: 'app',
    features: ['risk calculator', 'position sizing']
  }
}
```

### Adding Custom Templates

Edit `scripts/ai-build-webflow-pages.js`:

```javascript
const PAGE_TEMPLATES = {
  'my-page': {
    slug: 'my-page',
    name: 'My Page',
    title: 'My Page Title',
    requirements: {
      // Your requirements
    }
  }
};
```

---

## ⚡ GitHub Actions Workflow

### File: `.github/workflows/ai-webflow-builder.yml`

**Trigger:**
- Manual via Actions tab

**Steps:**
1. Checkout code
2. Install dependencies
3. Run AI page builder
4. Generate element IDs
5. Optimize for SEO
6. Report results

**Inputs:**
- `pages` - Which pages to build (comma-separated or 'all')
- `use_ai` - Enable/disable AI content generation

**Secrets Required:**
- `WEBFLOW_API_TOKEN`
- `WEBFLOW_SITE_ID`
- `PPLX_API_KEY` (optional)

---

## 📊 Workflow Examples

### Example 1: Build All Pages with AI

```bash
git pull origin main
npm install
npm run ai:webflow-full
```

**Output:**
```
🤖 AI-POWERED WEBFLOW PAGE BUILDER
========================================

📚 Checking existing pages...
✅ Found 2 existing pages

🎨 Building: Home (index)
   ⏭️  Skip: Already exists

🎨 Building: Pricing (pricing)
   🤖 Generating content with AI...
   📝 Creating page...
   ✅ Created: page_abc123
   💬 Content: Velg din plan

========================================
🎉 BUILD COMPLETE!
   Created: 1
   Skipped: 1
   Failed: 0
========================================
```

### Example 2: Generate Element IDs

```bash
npm run ai:generate-ids
```

**Output:**
```
🎯 Generating Element IDs with AI...

📝 dashboard:
   - signals list: #dashboard-signals-container
   - filter buttons: #dashboard-filter-buy
   - loading state: #dashboard-loading-spinner

✅ Element IDs generated!
```

### Example 3: SEO Optimization

```bash
npm run ai:seo-optimize
```

**Output:**
```
🔍 SEO Optimization with AI...

📝 landing:
   Title: Klarpakke - Trygg AI-Drevet Krypto Trading for Nordmenn
   Description: Start din trygge krypto-trading reise med AI-analyse...
   Headers: 4

✅ SEO optimization complete!
```

---

## 🔧 Advanced Configuration

### Custom AI Prompts

Edit `lib/ai-content-generator.js`:

```javascript
_buildPrompt(pageType, requirements) {
  return `
    Generate ${pageType} page content.
    
    Requirements: ${JSON.stringify(requirements)}
    
    Return JSON with:
    - headline (string)
    - subheadline (string)
    - body (string)
    - cta (string)
    - benefits (array)
  `;
}
```

### Rate Limiting

Default: 1 second between page creations

Edit `scripts/ai-build-webflow-pages.js`:

```javascript
// Change from 1000ms to 2000ms
await sleep(2000);
```

### Fallback Content

Works without `PPLX_API_KEY` using predefined templates.

Edit fallbacks in `lib/ai-content-generator.js`:

```javascript
_getFallbackContent(pageType) {
  const fallbacks = {
    landing: {
      headline: 'Your Headline Here',
      // ...
    }
  };
}
```

---

## ✅ Testing

### Test Webflow Connection

```bash
node -e "
const WebflowMCP = require('./lib/webflow-mcp');
const webflow = new WebflowMCP(
  process.env.WEBFLOW_API_TOKEN,
  process.env.WEBFLOW_SITE_ID
);
webflow.getSiteInfo().then(console.log);
"
```

### Test AI Content Generation

```bash
node -e "
const AI = require('./lib/ai-content-generator');
const ai = new AI(process.env.PPLX_API_KEY);
ai.generatePageContent('landing', { tone: 'friendly' })
  .then(console.log);
"
```

---

## 🚨 Troubleshooting

### Issue: "Webflow API Token Invalid"

**Solution:**
1. Go to Webflow Dashboard → Site Settings → Integrations
2. Generate new API token
3. Update `WEBFLOW_API_TOKEN` in `.env` and GitHub Secrets

### Issue: "Page Already Exists"

**Expected behavior.** Script skips existing pages.

To recreate:
1. Delete page in Webflow Designer
2. Re-run script

### Issue: "AI Content Generation Failed"

**Fallback content is used automatically.**

Check:
- `PPLX_API_KEY` is set correctly
- API key has credits remaining
- Network connectivity

### Issue: "Rate Limit Exceeded"

**Solution:**
- Increase sleep time between requests
- Reduce number of pages built at once
- Wait 1 minute and retry

---

## 📅 Roadmap

### Phase 1: Core Automation ✅
- [x] Webflow MCP wrapper
- [x] AI content generation
- [x] Page builder script
- [x] GitHub Actions workflow

### Phase 2: Enhanced Features 🔄
- [ ] Visual regression testing
- [ ] A/B testing support
- [ ] Multi-language content
- [ ] Image generation integration

### Phase 3: Advanced AI 🔮
- [ ] Auto-design from wireframes
- [ ] Conversational page builder
- [ ] Performance optimization AI
- [ ] Accessibility checker

---

## 🔗 Resources

- **Webflow API Docs:** https://developers.webflow.com/
- **Perplexity API:** https://docs.perplexity.ai/
- **GitHub Actions:** https://docs.github.com/actions
- **Project Repo:** https://github.com/tombomann/klarpakke

---

## 👥 Contributing

Improvements welcome!

1. Fork repo
2. Create feature branch
3. Make changes
4. Test thoroughly
5. Submit PR

---

**Last Updated:** 2026-01-29  
**Version:** 1.1.0
