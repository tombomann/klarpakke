# Webflow MCP Usage Guide

## Quick Reference

### Installation

```bash
npm install
```

### Usage in Scripts

```javascript
const WebflowMCP = require('./lib/webflow-mcp');

const webflow = new WebflowMCP(
  process.env.WEBFLOW_API_TOKEN,
  process.env.WEBFLOW_SITE_ID
);

// Use MCP methods
const result = await webflow.listPages();
```

---

## MCP Methods

### Site Management

#### `getSiteInfo()`
Get site information

```javascript
const info = await webflow.getSiteInfo();
console.log(info.site.displayName);
```

#### `publishSite(domains)`
Publish site to domains

```javascript
const result = await webflow.publishSite([
  'www.klarpakke.no'
]);
```

---

### Page Management

#### `listPages()`
List all pages

```javascript
const { pages, count } = await webflow.listPages();
pages.forEach(page => {
  console.log(`${page.name}: ${page.slug}`);
});
```

#### `getPage(slug)`
Get page by slug

```javascript
const { page } = await webflow.getPage('pricing');
if (page) {
  console.log(page.title);
}
```

#### `createPage(data)`
Create new page

```javascript
const result = await webflow.createPage({
  slug: 'about',
  name: 'About Us',
  title: 'About Klarpakke',
  isHomePage: false,
  isHidden: false
});

if (result.success) {
  console.log('Page ID:', result.pageId);
}
```

#### `updatePageMetadata(pageId, metadata)`
Update page metadata

```javascript
const result = await webflow.updatePageMetadata(pageId, {
  title: 'New Title',
  description: 'New meta description'
});
```

---

### Collection Management

#### `listCollections()`
List all CMS collections

```javascript
const { collections } = await webflow.listCollections();
collections.forEach(col => {
  console.log(`${col.displayName}: ${col.id}`);
});
```

#### `getCollectionItems(collectionId, options)`
Get items from collection

```javascript
const items = await webflow.getCollectionItems(
  'collection_abc123',
  { limit: 50, offset: 0 }
);

console.log(`Total: ${items.total}`);
items.items.forEach(item => {
  console.log(item.fieldData);
});
```

#### `createCollectionItem(collectionId, fields)`
Create CMS item

```javascript
const result = await webflow.createCollectionItem(
  'collection_abc123',
  {
    name: 'Signal #123',
    slug: 'signal-123',
    symbol: 'BTC',
    direction: 'BUY'
  }
);

if (result.success) {
  console.log('Created:', result.item.id);
}
```

---

## Error Handling

All methods return `{ success: boolean, ... }` format:

```javascript
const result = await webflow.createPage(data);

if (!result.success) {
  console.error('Error:', result.error);
  console.error('Status:', result.statusCode);
  // Handle error
} else {
  // Success
  console.log('Page created:', result.pageId);
}
```

---

## Best Practices

### 1. Check Before Creating

```javascript
// Check if page exists
const existing = await webflow.getPage('pricing');
if (!existing.page) {
  await webflow.createPage({ slug: 'pricing', ... });
}
```

### 2. Rate Limiting

```javascript
for (const page of pages) {
  await webflow.createPage(page);
  await sleep(1000); // 1 second between requests
}
```

### 3. Batch Operations

```javascript
const results = await Promise.allSettled(
  pages.map(page => webflow.createPage(page))
);

results.forEach((result, i) => {
  if (result.status === 'fulfilled') {
    console.log(`✅ ${pages[i].name}`);
  } else {
    console.error(`❌ ${pages[i].name}:`, result.reason);
  }
});
```

### 4. Environment Variables

```javascript
// Always use env vars, never hardcode
const webflow = new WebflowMCP(
  process.env.WEBFLOW_API_TOKEN,
  process.env.WEBFLOW_SITE_ID
);
```

---

## Examples

### Example 1: List All Pages and Collections

```javascript
const WebflowMCP = require('./lib/webflow-mcp');

async function listEverything() {
  const webflow = new WebflowMCP(
    process.env.WEBFLOW_API_TOKEN,
    process.env.WEBFLOW_SITE_ID
  );

  // Site info
  const site = await webflow.getSiteInfo();
  console.log('Site:', site.site.displayName);

  // Pages
  const pages = await webflow.listPages();
  console.log('\nPages:', pages.count);
  pages.pages.forEach(p => console.log(`  - ${p.name}`));

  // Collections
  const collections = await webflow.listCollections();
  console.log('\nCollections:', collections.collections.length);
  collections.collections.forEach(c => {
    console.log(`  - ${c.displayName}`);
  });
}

listEverything();
```

### Example 2: Create Multiple Pages

```javascript
const pages = [
  { slug: 'about', name: 'About', title: 'About Us' },
  { slug: 'contact', name: 'Contact', title: 'Contact Us' },
  { slug: 'faq', name: 'FAQ', title: 'FAQ' }
];

for (const page of pages) {
  const result = await webflow.createPage(page);
  console.log(result.success ? '✅' : '❌', page.name);
  await sleep(1000);
}
```

### Example 3: Sync Database to CMS

```javascript
async function syncSignals(signals) {
  const collectionId = process.env.WEBFLOW_SIGNALS_COLLECTION_ID;

  for (const signal of signals) {
    const result = await webflow.createCollectionItem(
      collectionId,
      {
        name: `${signal.symbol} ${signal.direction}`,
        slug: `signal-${signal.id}`,
        symbol: signal.symbol,
        direction: signal.direction,
        price: signal.price
      }
    );

    console.log(
      result.success ? '✅' : '❌',
      signal.symbol
    );

    await sleep(500);
  }
}
```

---

## Debugging

### Enable Verbose Logging

Edit `lib/webflow-mcp.js`:

```javascript
async listPages() {
  console.log('🔍 Fetching pages...');
  const response = await this.client.get(`/sites/${this.siteId}/pages`);
  console.log('✅ Response:', response.data);
  // ...
}
```

### Test Connection

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

---

## API Limits

**Webflow API Limits:**
- 60 requests per minute
- Use rate limiting (1 request/second is safe)

**Best Practice:**
```javascript
const RATE_LIMIT_MS = 1000;

for (const item of items) {
  await processItem(item);
  await sleep(RATE_LIMIT_MS);
}
```

---

## Resources

- **Webflow API Docs:** https://developers.webflow.com/reference/rest-introduction
- **API v2 Migration:** https://developers.webflow.com/reference/migration-guide
- **Rate Limits:** https://developers.webflow.com/reference/rate-limits

---

**Last Updated:** 2026-01-29
