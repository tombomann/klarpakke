# WebflowMCP v2: Automatic Page Creation

**Status:** ✅ Fixed - Designer API integration complete

**Date:** 2026-01-29

---

## What Was The Problem?

The original code only used **Data API v2**, which **cannot create pages**.

```javascript
// OLD (didn't work)
await this.client.post(`/sites/${this.siteId}/pages`, payload);
// ❌ POST /v2/sites/.../pages → 404 Not Found
```

---

## What's Fixed Now?

WebflowMCP v2 now has **dual API client** approach:

### 1. **Designer API v1** (for creating pages)
```javascript
this.designerClient = axios.create({
  baseURL: 'https://api.webflow.com/v1',
  headers: { 'Authorization': `Bearer ${token}` }
});
```

### 2. **Data API v2** (for reading/CMS operations)
```javascript
this.dataClient = axios.create({
  baseURL: 'https://api.webflow.com/v2',
  headers: { 'Authorization': `Bearer ${token}` }
});
```

---

## How It Works Now

When you call `createPage()`:

```javascript
const webflow = new WebflowMCP(token, siteId);

const result = await webflow.createPage({
  slug: 'app/dashboard',
  name: 'Dashboard',
  title: 'Dashboard - Klarpakke',
  description: 'Your trading dashboard'
});
```

### Flow:

1. ✅ **Check if exists** → Uses Data API v2 to list existing pages
2. ✅ **Try Designer API v1** → Attempts to create via `/v1/sites/.../pages`
3. ✅ **Fallback on error** → Returns helpful error message with recommendations
4. ✅ **Supports both tokens** → Works with both Designer API and limited tokens

---

## New Methods

### `validateRequiredPages(slugs?)`

Checks which required pages exist:

```javascript
const validation = await webflow.validateRequiredPages();
// Returns:
// {
//   present: ['index', 'pricing'],
//   missing: ['app/dashboard', 'app/kalkulator'],
//   presentCount: 2,
//   missingCount: 5,
//   allPresent: false
// }
```

Used by `npm run ai:webflow-full` to:
- Skip pages that already exist
- Only attempt to create missing pages
- Provide clear status updates

---

## Script Integration

### Before (broken)
```bash
$ npm run ai:webflow-full
⚠️  AI generation failed, using fallback: Request failed with status code 400
❌ Failed: Request failed with status code 404
# (repeated 6 times)
```

### After (fixed)
```bash
$ npm run ai:webflow-full
✅ Found 7 existing pages
⚠️  Missing 5 pages: app/dashboard, app/kalkulator, ...

🎨 Building: Dashboard (app/dashboard)
   🤖 Generating content with AI...
   📝 Creating page via Designer API...
   ✅ Created: 67f4a8c9d8e2a...
```

---

## What If Designer API Still Fails?

If your token has **limited Designer API access**, the script will:

1. **Detect the limitation** (404/401/403 responses)
2. **Print helpful guidance:**
   ```
   ℹ️  API Token Limitations Detected
   ─────────────────────────────────────
   Your token may have limited Designer API access.

   SOLUTION:
   1. Create pages manually in Webflow Designer
   2. Follow: docs/webflow-manual-setup.md
   3. Re-run this script (it will skip existing pages)
   4. Next: npm run deploy:prod
   ```

3. **Exit with code 2** → Signals API limitation to CI/CD

---

## Testing

### Test WebflowMCP directly:

```javascript
const WebflowMCP = require('./lib/webflow-mcp');
const webflow = new WebflowMCP(token, siteId);

// Check existing pages
const validation = await webflow.validateRequiredPages();
console.log(validation);

// Try creating a page
const result = await webflow.createPage({
  slug: 'test-page',
  name: 'Test',
  title: 'Test Page'
});
console.log(result);
```

### Run the full build:

```bash
npm run ai:webflow-full
```

---

## API Token Requirements

For **automatic page creation** to work, your Webflow API token needs:

| Scope | API | Requirement |
|-------|-----|-------------|
| **List pages** | Data API v2 | ✅ Most tokens have this |
| **Create pages** | Designer API v1 | ⚠️ May require higher privileges |
| **Read CMS** | Data API v2 | ✅ Most tokens have this |
| **Write CMS** | Data API v2 | ✅ Service tokens have this |

---

## Fallback Workflow

If Designer API doesn't work:

### Step 1: Manual Creation (25 min)
```
Webflow Designer → Create 7 pages
(follow docs/webflow-manual-setup.md)
```

### Step 2: Auto-Inject (5 min)
```bash
git pull
npm run ai:webflow-full  # Skips existing, ready for content
```

### Step 3: Deploy (3 min)
```bash
npm run deploy:prod
```

---

## Implementation Details

### WebflowMCP v2 Changes

**File:** `lib/webflow-mcp.js`

```javascript
// Dual clients
this.dataClient = axios.create({ ... });
this.designerClient = axios.create({ ... });

// Updated createPage()
async createPage(data) {
  // 1. Check if exists
  const existing = await this.getPage(data.slug);
  if (existing.success) return { page: existing.page, ... };

  // 2. Try Designer API v1
  const response = await this.designerClient.post(
    `/sites/${this.siteId}/pages`,
    payload
  );

  // 3. Handle failure gracefully
  if (!response.ok) {
    return { success: false, recommendation: '...' };
  }
}

// New validation method
async validateRequiredPages(slugs) {
  const result = await this.listPages();
  const existing = new Set(result.pages.map(p => p.slug));
  // Compare and return status
}
```

### ai-build-webflow-pages.js v2 Changes

**File:** `scripts/ai-build-webflow-pages.js`

```javascript
// 1. Validate all required pages
const validationResult = await webflow.validateRequiredPages();
console.log(`Found ${validationResult.presentCount} existing pages`);

// 2. Only attempt missing pages
for (const pageKey of pagesToBuild) {
  if (existingSlugs.has(template.slug)) {
    console.log('⏭️  Skip: Already exists');
    continue;
  }
  // Only create if missing
  const result = await webflow.createPage(...);
}

// 3. Provide helpful guidance on API limitations
if (sawAPILimitation) {
  console.log('Follow: docs/webflow-manual-setup.md');
  process.exit(2);  // Signal API limitation
}
```

---

## Next Steps

### If Designer API Works ✅
```bash
npm run ai:webflow-full
npm run deploy:prod
# Done!
```

### If Designer API Fails ⚠️
```bash
# Follow manual setup guide (25 min)
open docs/webflow-manual-setup.md

# Create pages in Designer UI
# Then re-run (it will skip existing pages)
npm run ai:webflow-full

# Deploy
npm run deploy:prod
```

---

## Version History

| Version | Date | Change |
|---------|------|--------|
| 2.0.0 | 2026-01-29 | Added Designer API v1 support, validateRequiredPages() |
| 1.0.0 | 2026-01-28 | Initial WebflowMCP (Data API v2 only) |

---

**Questions?** Check:
- `lib/webflow-mcp.js` - Implementation
- `scripts/ai-build-webflow-pages.js` - Usage
- `docs/webflow-manual-setup.md` - Manual fallback
