# 🚀 Automatic Webflow Pages Setup (Quick Start)

**Goal:** Create 6 pages automatically in Webflow + prepare them for custom code injection

**Time:** 5 minutes to set up + 30 minutes manual in Designer

---

## Step 1: Prepare Credentials (2 min)

### Get Webflow API Token

1. Go to: https://webflow.com/account/tokens
2. Click **Generate Token**
3. Select **Full access** scope
4. Copy the token (you’ll use it once)

### Get Webflow Site ID

1. Go to: https://webflow.com/dashboard
2. Find **Klarpakke** project
3. Click **Project Settings** → **General**
4. Copy **Site ID** from top of page

---

## Step 2: Set GitHub Secrets (2 min)

1. Go to your GitHub repo: https://github.com/tombomann/klarpakke
2. **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add two secrets:

   **Secret 1:**
   - Name: `WEBFLOW_API_TOKEN`
   - Value: (paste your token)
   - Click **Add secret**

   **Secret 2:**
   - Name: `WEBFLOW_SITE_ID`
   - Value: (paste your site ID)
   - Click **Add secret**

---

## Step 3: Run Page Creation (1 min)

### Option A: GitHub Actions (Recommended)

1. Go to: https://github.com/tombomann/klarpakke/actions
2. Find: **📄 Create Webflow Pages (Automated)**
3. Click **Run workflow** → **Run workflow**
4. Wait for ✅ green checkmark (< 1 minute)

### Option B: Local Command

```bash
# Set env vars temporarily
export WEBFLOW_API_TOKEN="your_token_here"
export WEBFLOW_SITE_ID="your_site_id_here"

# Run script
node scripts/create-webflow-pages.js
```

### Option C: npm Script

```bash
# Requires env vars set in .env or terminal
npm run webflow:create-pages
```

---

## Step 4: Verify Pages in Designer (2 min)

1. Go to: https://webflow.com/dashboard/sites/klarpakke/designer
2. Click **Pages** panel (left sidebar)
3. You should see all 6 pages:
   - ✅ Home (`index`)
   - ✅ Pricing (`pricing`)
   - ✅ Dashboard (`app/dashboard`)
   - ✅ Kalkulator (`app/kalkulator`)
   - ✅ Settings (`app/settings`)
   - ✅ Login (`login`)

---

## Step 5: Add Element IDs (15 min)

Now you need to add required element IDs to each page.

### For each page:

1. Click page name in **Pages** panel
2. Designer opens that page
3. Add elements (divs, buttons, etc.) with required IDs
4. See detailed instructions below

### Home Page Example

```
Add these elements with IDs:
├─ <div id="cta-primary">
├─ <button id="cta-demo">
├─ <section id="features">
└─ <footer id="footer">
```

**Full list:** See [`docs/WEBFLOW-ELEMENT-IDS.md`](docs/WEBFLOW-ELEMENT-IDS.md)

---

## Step 6: Add Custom Code (10 min)

For each page that needs scripts:

1. **Open page** in Designer
2. Click **Settings** (⚙️ icon, top right)
3. Scroll to **Custom code**
4. Add code snippets

### Example: Home Page

**In "Head code" section:**
```html
<title>Klarpakke - Trygg Krypto-Trading med AI</title>
<meta name="description" content="Din AI-drevne kryptotradingassistent for nordiske investorer.">
```

**In "Before </body> code" section:**
```html
<script src="/scripts/klarpakke-site.js"></script>
```

**See:** [`docs/WEBFLOW-AUTO-PAGES.md`](docs/WEBFLOW-AUTO-PAGES.md) for details

---

## Step 7: Publish (1 min)

1. In Webflow Designer, click **Publish** button (top right)
2. Select **Publish to live**
3. Wait for green ✅ confirmation
4. Done! 🎉

---

## What Just Happened?

```
✅ Step 1-2: Got credentials
   ✅ Step 3: Created 6 pages via API
   ✅ Step 4: Verified pages exist
   ✅ Step 5: Added element IDs (your work)
   ✅ Step 6: Added custom code (your work)
   ✅ Step 7: Published site
```

Your Klarpakke website is now **ready for API integration**!

---

## Troubleshooting

### "Pages not appearing?"

1. Hard refresh Designer: `Cmd+Shift+R` or `Ctrl+Shift+R`
2. Close and reopen Webflow Designer
3. Check GitHub Actions workflow logs for errors

### "API Token not working?"

1. Check token doesn’t have leading/trailing spaces
2. Verify secret is saved (go to Secrets page, it should be listed)
3. Generate new token if unsure

### "Element IDs not working?"

1. Make sure you’re adding **to actual elements** (not text)
2. Use **exact ID names** from WEBFLOW-ELEMENT-IDS.md
3. IDs are case-sensitive: `#MyId` ≠ `#myid`
4. Use **Settings panel** to set IDs (top right ⚙️)

---

## Next Steps After Setup

1. **Design your pages** - Use Webflow to add content
2. **Test locally** - Hard refresh in browser
3. **Check console** - DevTools Console should show `[Klarpakke]` messages
4. **Deploy backend** - `npm run deploy:backend`
5. **Run health check** - `npm run health:full`

---

## Questions?

See full documentation:
- [`docs/WEBFLOW-AUTO-PAGES.md`](docs/WEBFLOW-AUTO-PAGES.md) – Complete guide
- [`docs/WEBFLOW-ELEMENT-IDS.md`](docs/WEBFLOW-ELEMENT-IDS.md) – Required IDs
- [`docs/DESIGN.md`](docs/DESIGN.md) – Design system
- [`docs/COPY.md`](docs/COPY.md) – Content templates

Open [GitHub Issue](https://github.com/tombomann/klarpakke/issues) if stuck.
