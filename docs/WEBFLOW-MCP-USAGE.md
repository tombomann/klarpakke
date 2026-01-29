# Webflow MCP API Reference

**Version:** 1.0.0  
**Last Updated:** 2026-01-29

---

## 📖 Overview

The Webflow MCP (Model Context Protocol) library provides a clean interface for programmatic Webflow site management.

---

## 🚀 Quick Start

```javascript
const WebflowMCP = require('./lib/webflow-mcp');

const webflow = new WebflowMCP(
  process.env.WEBFLOW_API_TOKEN,
  process.env.WEBFLOW_SITE_ID
);

// List pages
const pages = await webflow.listPages();
console.log(pages);
```

---

## 🔑 Authentication

### Get API Token

1. Go to **Webflow Dashboard**
2. Select your site
3. **Site Settings → Integrations → API Access**
4. Generate API token (v2)
5. Copy token to `.env`:

```bash
WEBFLOW_API_TOKEN=wfp_xxx
WEBFLOW_SITE_ID=xxx
```

---

## 📚 API Methods

### Site Info

#### `getSiteInfo()`

Get site information.

```javascript
const result = await webflow.getSiteInfo();

if (result.success) {
  console.log('Site:', result.data.displayName);
} else {
  console.error('Error:', result.error);
}
```

**Response:**
```javascript
{
  success: true,
  data: {
    id: 'xxx',
    displayName: 'Klarpakke',
    shortName: 'klarpakke',
    customDomains: ['www.klarpakke.no']
  }
}
```

---

### Pages

#### `listPages()`

List all pages in site.

```javascript
const result = await webflow.listPages();

console.log(`Found ${result.count} pages`);
result.pages.forEach(page => {
  console.log(`- ${page.name} (${page.slug})`);
});
```

**Response:**
```javascript
{
  success: true,
  pages: [
    {
      id: 'page_xxx',
      slug: 'index',
      name: 'Home',
      title: 'Klarpakke - Home'
    }
  ],
  count: 1
}
```

#### `getPage(slug)`

Get specific page by slug.

```javascript
const result = await webflow.getPage('pricing');

if (result.success) {
  console.log('Page ID:', result.page.id);
}
```

#### `createPage(data)`

Create new page.

```javascript
const result = await webflow.createPage({
  slug: 'pricing',
  name: 'Pricing',
  title: 'Klarpakke - Priser',
  description: 'Velg din plan',
  openGraph: {
    title: 'Klarpakke Pricing',
    description: 'Velg din plan'
  }
});

if (result.success) {
  console.log('Created:', result.pageId);
}
```

**Parameters:**
- `slug` (required) - URL slug (e.g., 'pricing')
- `name` (required) - Display name
- `title` (required) - Page title
- `description` (optional) - Meta description
- `openGraph` (optional) - Open Graph metadata

#### `updatePageMetadata(pageId, metadata)`

Update page metadata.

```javascript
const result = await webflow.updatePageMetadata('page_xxx', {
  seo: {
    title: 'New Title',
    description: 'New description'
  }
});
```

#### `pageExists(slug)`

Check if page exists.

```javascript
const exists = await webflow.pageExists('pricing');
if (exists) {
  console.log('Page exists!');
}
```

---

### CMS Collections

#### `listCollections()`

List all CMS collections.

```javascript
const result = await webflow.listCollections();

result.collections.forEach(col => {
  console.log(`- ${col.displayName} (${col.id})`);
});
```

#### `getCollectionItems(collectionId, options)`

Get collection items.

```javascript
const result = await webflow.getCollectionItems('col_xxx', {
  limit: 100,
  offset: 0
});

console.log(`Got ${result.count} items`);
```

**Options:**
- `limit` (default: 100) - Max items to return
- `offset` (default: 0) - Pagination offset

#### `createCollectionItem(collectionId, fields)`

Create CMS item.

```javascript
const result = await webflow.createCollectionItem('col_xxx', {
  name: 'BTC Signal',
  slug: 'btc-signal-123',
  symbol: 'BTC',
  direction: 'BUY',
  price: 50000
});

if (result.success) {
  console.log('Created:', result.item.id);
}
```

#### `updateCollectionItem(collectionId, itemId, fields)`

Update CMS item.

```javascript
const result = await webflow.updateCollectionItem(
  'col_xxx',
  'item_xxx',
  { price: 51000 }
);
```

---

### Publishing

#### `publishSite(domains)`

Publish site to domains.

```javascript
// Publish to all domains
await webflow.publishSite();

// Publish to specific domains
await webflow.publishSite(['www.klarpakke.no']);
```

---

## 🚨 Error Handling

All methods return structured responses:

```javascript
{
  success: true,  // or false
  data: {...},    // on success
  error: '...',   // on failure
  status: 404,    // HTTP status (if error)
  method: '...'   // Method name (if error)
}
```

**Example:**

```javascript
const result = await webflow.createPage({...});

if (result.success) {
  console.log('✅ Success:', result.pageId);
} else {
  console.error('❌ Error:', result.error);
  if (result.status === 401) {
    console.error('Invalid API token');
  }
}
```

---

## 🧩 Testing

### Connection Test

```bash
node -e "
const WebflowMCP = require('./lib/webflow-mcp');
const w = new WebflowMCP(
  process.env.WEBFLOW_API_TOKEN,
  process.env.WEBFLOW_SITE_ID
);
w.getSiteInfo().then(r => {
  if (r.success) {
    console.log('✅ Connected to:', r.data.displayName);
  } else {
    console.log('❌ Failed:', r.error);
  }
});
"
```

---

## 🔗 Resources

- **Webflow API v2:** https://developers.webflow.com/
- **GitHub Repo:** https://github.com/tombomann/klarpakke
- **Integration Guide:** `docs/AI-WEBFLOW-INTEGRATION.md`
