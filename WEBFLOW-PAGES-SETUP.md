# 🚀 Automatic Webflow Pages Setup (1-Click)

**Goal:** Create 6 pages automatically in Webflow

**Time:** < 2 minutes (secrets already configured! ✅)

---

## ✅ Prerequisites (Already Done!)

Your repo already has:
- ✅ `WEBFLOW_API_TOKEN` in GitHub Secrets
- ✅ `WEBFLOW_SITE_ID` in GitHub Secrets
- ✅ All secrets synced from Supabase

**No setup needed!** Just run the automation.

---

## Step 1: Run Page Creation (< 1 min)

### Option A: GitHub Actions (Recommended) ⭐

1. Go to: https://github.com/tombomann/klarpakke/actions
2. Find: **📄 Create Webflow Pages (Automated)**
3. Click **Run workflow** → **Run workflow**
4. Wait for ✅ green checkmark (< 1 minute)

### Option B: Local Command

```bash
# Secrets are already in .env (synced from Supabase)
npm run webflow:create-pages
```

### Option C: npm Script with Manual Env

```bash
# If .env is missing, pull from Supabase first:
npm run secrets:pull-supabase

# Then run:
npm run webflow:create-pages
```

---

## Step 2: Verify Pages in Designer (1 min)

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

## Step 3: Add Element IDs (15 min)

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

## Step 4: Add Custom Code (10 min)

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

## Step 5: Publish (1 min)

1. In Webflow Designer, click **Publish** button (top right)
2. Select **Publish to live**
3. Wait for green ✅ confirmation
4. Done! 🎉

---

## What Just Happened?

```
✅ Secrets already configured (Supabase + GitHub)
   ✅ Step 1: Ran automation via GitHub Actions
   ✅ Step 2: Verified pages exist
   ✅ Step 3: Added element IDs (your work)
   ✅ Step 4: Added custom code (your work)
   ✅ Step 5: Published site
```

Your Klarpakke website is now **ready for API integration**!

---

## Secret Management

All secrets are already synced between:
- 🔐 **Supabase** (source of truth)
- 🔐 **GitHub Secrets** (for CI/CD)
- 🔐 **Local `.env`** (for development)

### Useful Commands

```bash
# Pull secrets from Supabase to local .env
npm run secrets:pull-supabase

# Push secrets from local .env to Supabase
npm run secrets:push-supabase

# Push secrets to GitHub
npm run secrets:push-github

# Validate all secrets
npm run secrets:validate
```

**No manual setup needed!** Your automation team already configured everything.

---

## Troubleshooting

### "Pages not appearing?"

1. Hard refresh Designer: `Cmd+Shift+R` or `Ctrl+Shift+R`
2. Close and reopen Webflow Designer
3. Check GitHub Actions workflow logs for errors

### "API Token not working?"

```bash
# Validate secrets
npm run secrets:validate

# Pull latest from Supabase
npm run secrets:pull-supabase
```

### "Element IDs not working?"

1. Make sure you're adding **to actual elements** (not text)
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

---

## 🎯 Ready to Launch?

**Total time: < 30 minutes from automation to live site!**

1. ✅ Secrets already configured
2. 🚀 Run GitHub Actions workflow (< 1 min)
3. 📝 Add element IDs (15 min)
4. 💻 Add Custom Code (10 min)
5. 🎨 Design pages (flexible)
6. 📤 Publish (1 min)

**Go to GitHub Actions and click "Run workflow" now! →** https://github.com/tombomann/klarpakke/actions
