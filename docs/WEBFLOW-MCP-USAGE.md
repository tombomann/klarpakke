// NOTE: This file documents *desired* functionality.
// In practice, creating pages is done via Webflow Designer API (App/Designer extension),
// while this wrapper focuses on Webflow Data API v2 (pages listing/metadata, CMS, publish).

# Webflow MCP API Reference

**Version:** 1.0.0  
**Last Updated:** 2026-01-29

---

## 📖 Overview

The Webflow MCP library provides a clean interface for programmatic Webflow site management.

Important: Webflow has multiple APIs. In our stack:
- **Data API v2**: CMS (collections/items), publishing, listing pages and reading/updating page metadata (where supported).
- **Designer API**: Creating pages/folders and changing Designer-level structure (requires a Webflow App / Designer extension).

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

### Pages

#### `listPages()`

List all pages in site.

#### `createPage(data)`

⚠️ **Designer API required**

Creating pages is typically **not available** through the Data API endpoint `POST /v2/sites/{siteId}/pages` and may return 404.

Use a Webflow **Designer extension** to call the Designer API method `webflow.createPage()`:
- Docs: https://developers.webflow.com/designer/reference/create-page

This repo will provide a `webflow-designer-extension/` package for page creation (next step).

---

### CMS Collections

`listCollections()`, `getCollectionItems()`, `createCollectionItem()`, etc. are supported via Data API v2.

---

### Publishing

`publishSite(domains)` is supported via Data API v2.

---

## 🔗 Resources

- Webflow Developer Docs: https://developers.webflow.com/
- Webflow Designer API (Create page): https://developers.webflow.com/designer/reference/create-page
