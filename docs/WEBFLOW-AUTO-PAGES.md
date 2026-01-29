# 🤖 Automatic Webflow Page Creation

**Status:** ✅ Production-Ready  
**Last Updated:** 2026-01-29

---

## Overview

This automation **creates 6 required Webflow pages** using the Webflow API:

1. **Home** (`/index`)
2. **Pricing** (`/pricing`)
3. **Dashboard** (`/app/dashboard`)
4. **Calculator** (`/app/kalkulator`)
5. **Settings** (`/app/settings`)
6. **Login** (`/login`)

⚠️ **Important:** The Webflow API v2 can only **CREATE** pages, not inject full HTML content or Custom Code directly. After creation, you must:
- Add **element IDs** in Webflow Designer
- Add **Custom Code** in Page Settings
- Design pages with Webflow components

---

## Quick Start

### Option 1: Local Command

```bash
# Set environment variables
export WEBFLOW_API_TOKEN="your_token_here"
export WEBFLOW_SITE_ID="your_site_id_here"

# Run locally
node scripts/create-webflow-pages.js
```

**Requirements:**
- Node.js 18+
- `WEBFLOW_API_TOKEN` environment variable
- `WEBFLOW_SITE_ID` environment variable

### Option 2: GitHub Actions

```bash
# Make sure GitHub Secrets are set:
# - WEBFLOW_API_TOKEN
# - WEBFLOW_SITE_ID

# Then trigger the workflow:
git push  # Auto-runs on push
# OR manually trigger:
# Go to Actions → Create Webflow Pages → Run workflow
```

### Option 3: npm Script

```bash
# Requires env vars set
npm run webflow:create-pages
```

---

## Environment Setup

### Get Your Webflow Credentials

**Step 1: Get API Token**
1. Go to [webflow.com/account/tokens](https://webflow.com/account/tokens)
2. Click **Generate Token** → **Full access** → Copy token
3. Save as `WEBFLOW_API_TOKEN`

**Step 2: Get Site ID**
1. Go to [webflow.com/dashboard](https://webflow.com/dashboard)
2. Click your **Klarpakke** project
3. Go to **Project Settings** → **General** → Copy **Site ID**
4. Save as `WEBFLOW_SITE_ID`

### Set GitHub Secrets

1. Go to **GitHub** → **Settings** → **Secrets and variables** → **Actions**
2. Click **New repository secret**
3. Add:
   - `WEBFLOW_API_TOKEN` = your_token
   - `WEBFLOW_SITE_ID` = your_site_id

---

## What the Script Does

### Page Creation Workflow

```
1. Read page definitions from PAGES array
2. Fetch existing pages via Webflow API
3. For each new page:
   ├─ Create page with name + slug
   ├─ Update metadata (title, description)
   ├─ Log for Custom Code injection
4. Report summary (created, skipped, failed)
```

### Page Definitions

| Slug | Name | Purpose | IDs Required |
|------|------|---------|---------------|
| `index` | Home | Landing page | `#cta-primary`, `#cta-demo`, `#features`, `#footer` |
| `pricing` | Pricing | Pricing page | `#plan-tier-1`, `#plan-tier-2`, `#plan-tier-3` |
| `app/dashboard` | Dashboard | User dashboard | `#app-root`, `#sidebar`, `#main-content`, `#signals-feed` |
| `app/kalkulator` | Kalkulator | Risk calculator | `#calculator-root`, `#calc-input-1`, `#calc-submit` |
| `app/settings` | Settings | User settings | `#app-root`, `#form-settings`, `#btn-logout` |
| `login` | Login | Login page | `#form-login`, `#form-email`, `#form-password` |

---

## After Page Creation

### Step 1: Verify Pages in Designer

1. Open [Webflow Designer](https://webflow.com/dashboard/sites/klarpakke/designer)
2. Check **Pages** panel (left sidebar)
3. You should see all 6 new pages

### Step 2: Add Element IDs

For each page, add required element IDs:

**Example: Home Page**
```
1. Add <div> with ID: cta-primary
2. Add <button> with ID: cta-demo
3. Add <section> with ID: features
4. Add <footer> with ID: footer
```

**See:** [`WEBFLOW-ELEMENT-IDS.md`](WEBFLOW-ELEMENT-IDS.md) for complete list

### Step 3: Add Custom Code

For each page:

1. **Open page** in Designer
2. Click **Settings** (⚙️ top right)
3. Scroll to **Custom code**
4. Add **Head code** (if applicable)
5. Add **Before </body> code** (if applicable)

**Example: Home Page**

**Head code:**
```html
<title>Klarpakke - Trygg Krypto-Trading med AI</title>
<meta name="description" content="Din AI-drevne kryptotradingassistent for nordiske investorer.">
```

**Before </body> code:**
```html
<script src="/scripts/klarpakke-site.js"></script>
```

### Step 4: Design Pages

- Use Webflow's visual builder
- Add sections, divs, buttons as needed
- Reference element IDs in IDs doc
- Test in preview mode

### Step 5: Publish

```bash
# In Webflow Designer
Click "Publish" → "Publish to live" → Wait for completion
```

---

## Troubleshooting

### "Page already exists"

**Problem:** Script says page exists but you can't find it

**Solution:**
1. Check **Pages** panel in Designer
2. Scroll down for archived pages
3. If archived, right-click → **Restore**
4. Try running script again

### "API Authentication Failed"

**Problem:** `401 Unauthorized` error

**Solution:**
1. Verify `WEBFLOW_API_TOKEN` is correct (no spaces/typos)
2. Check token hasn't expired
3. Generate new token at [webflow.com/account/tokens](https://webflow.com/account/tokens)
4. Update GitHub Secrets

### "Site ID not found"

**Problem:** `404 Not Found` error

**Solution:**
1. Verify `WEBFLOW_SITE_ID` is correct
2. Check you have access to the Klarpakke project
3. Try copying Site ID again from Project Settings
4. Update GitHub Secrets

### "Custom Code not injecting"

**Problem:** Scripts not running on pages

**Solution:**
1. Verify Custom Code is added in Page Settings (not inline elements)
2. Use `<script src="...">` not inline code
3. Check browser console for errors
4. Hard refresh page (`Cmd+Shift+R` / `Ctrl+Shift+R`)

---

## Manual Page Creation (Fallback)

If automation fails, see [`WEBFLOW-MANUAL.md`](WEBFLOW-MANUAL.md) for step-by-step manual instructions.

---

## API Rate Limiting

**Webflow API Limits:**
- 60 requests per minute (per account)
- Burst limit: 120 per minute

**Our script:** Uses ~7-10 requests total → No issues

---

## Next Steps

After page creation:

1. ✅ **Pages created** → Verify in Designer
2. ➡️ **Add element IDs** → See WEBFLOW-ELEMENT-IDS.md
3. ➡️ **Add Custom Code** → Inject scripts
4. ➡️ **Design pages** → Use Webflow components
5. ➡️ **Test** → Preview + DevTools console
6. ➡️ **Publish** → Go live

---

## Related Documentation

- [`WEBFLOW-MANUAL.md`](WEBFLOW-MANUAL.md) - Manual page creation
- [`WEBFLOW-ELEMENT-IDS.md`](WEBFLOW-ELEMENT-IDS.md) - Required IDs per page
- [`DESIGN.md`](DESIGN.md) - Design system
- [`COPY.md`](COPY.md) - Content for pages

---

## Support

**Issue?** Check:
1. GitHub Actions logs → `Actions` tab → `Create Webflow Pages` → Latest run
2. Environment variables → `Settings` → `Secrets and variables`
3. API credentials → Webflow account settings

For bugs or questions, open a [GitHub Issue](https://github.com/tombomann/klarpakke/issues).
