# 🎨 Webflow Designer Setup Guide

**Goal:** Create 6 pages manually in Webflow Designer  
**Time:** 20-30 minutes  
**Reason:** Webflow API v2 does not support page creation - manual Designer workflow required

---

## ⚠️ Important: API Limitation

**Webflow Data API (v2) cannot create pages** — only list them. You must:
1. Create pages **manually in Webflow Designer**
2. Then scripts will inject content via **Custom Code**

This is a Webflow platform limitation, not a bug in our automation.

---

## 📅 Pages to Create (6 Total)

| # | Page Name | Slug | Purpose |
|---|-----------|------|----------|
| 1 | Home | `index` | Landing page |
| 2 | Pricing | `pricing` | Pricing tiers |
| 3 | Dashboard | `app/dashboard` | User dashboard |
| 4 | Kalkulator | `app/kalkulator` | Risk calculator |
| 5 | Settings | `app/settings` | User settings |
| 6 | Login | `login` | Authentication |

---

## 🚀 Step-by-Step Instructions

### Step 1: Open Webflow Designer (2 min)

1. Go to: https://webflow.com/dashboard
2. Open project: **Klarpakke**
3. Click **Designer** button
4. You should see existing page: **Pricing** (or empty project)

---

### Step 2: Create Pages (5 min)

For each page:

1. Click **Pages** panel (left sidebar)
2. Click **+** icon (top-right of Pages panel)
3. Enter page details:
   - **Name:** (see table above)
   - **Slug:** (see table above)
4. Click **Create**
5. Repeat for all 6 pages

**Tip:** For nested pages like `app/dashboard`, Webflow will auto-create the `app/` folder.

---

### Step 3: Add Element IDs (15 min)

**Why?** Scripts need specific element IDs to inject content dynamically.

#### Home Page (`/index`)

```html
<!-- Add these elements with IDs -->
<div id="cta-primary">Start Demo</div>
<button id="cta-demo">Learn More</button>
<section id="features">Features grid here</section>
<footer id="footer">Footer content</footer>
```

#### Dashboard (`/app/dashboard`)

```html
<div id="app-root">
  <nav id="sidebar">Sidebar navigation</nav>
  <main id="main-content">
    <div id="signals-feed">Signal cards here</div>
  </main>
</div>
```

#### Kalkulator (`/app/kalkulator`)

```html
<div id="calculator-root">
  <form id="calculator-form">
    <input id="calc-input-1" type="number" placeholder="Beløp">
    <input id="calc-input-2" type="number" placeholder="Rente">
    <button id="calc-submit">Beregn</button>
    <button id="calc-reset">Reset</button>
  </form>
  <div id="calc-result" class="hidden">
    <p id="calc-result-text">Result here</p>
  </div>
</div>
```

**Full list:** [`docs/WEBFLOW-ELEMENT-IDS.md`](docs/WEBFLOW-ELEMENT-IDS.md)

**How to add IDs:**
1. Select element in Designer
2. Open Settings panel (right sidebar)
3. Scroll to **Element Settings**
4. Add ID in **ID** field
5. Save

---

### Step 4: Add Custom Code (10 min)

For each page that needs scripts:

1. Open page in Designer
2. Click **Settings** (⚙️ icon, top right)
3. Scroll to **Custom code** section
4. Add code snippets

#### Example: Home Page

**Head code:**
```html
<title>Klarpakke - Trygg Krypto-Trading med AI</title>
<meta name="description" content="Din AI-drevne kryptotradingassistent for nordiske investorer.">
<meta property="og:title" content="Klarpakke">
<meta property="og:description" content="AI-drevet krypto trading.">
```

**Before </body> code:**
```html
<script src="/scripts/klarpakke-site.js"></script>
```

#### Example: Dashboard

**Head code:**
```html
<title>Dashboard - Klarpakke</title>
```

**Before </body> code:**
```html
<script src="/scripts/klarpakke-site.js"></script>
```

#### Example: Kalkulator

**Head code:**
```html
<title>Risiko-Kalkulator - Klarpakke</title>
```

**Before </body> code:**
```html
<script src="/scripts/calculator.js"></script>
```

**See:** [`docs/WEBFLOW-MANUAL.md`](docs/WEBFLOW-MANUAL.md) for complete code snippets

---

### Step 5: Design Pages (20+ min)

1. Use Webflow's visual builder
2. Add sections, divs, buttons as needed
3. Reference design system: [`docs/DESIGN.md`](docs/DESIGN.md)
4. Reference copy: [`docs/COPY.md`](docs/COPY.md)
5. Test in preview mode

---

### Step 6: Publish (1 min)

1. Click **Publish** button (top right)
2. Select **Publish to live**
3. Wait for green ✅ confirmation
4. Done! 🎉

---

## ✅ Verification Checklist

After creating all pages:

- [ ] All 6 pages exist in Pages panel
- [ ] Each page has correct slug
- [ ] Element IDs are added to all required elements
- [ ] Custom Code is added to page settings (not inline)
- [ ] Pages are designed with Webflow components
- [ ] Site is published
- [ ] Browser console shows `[Klarpakke]` logger messages
- [ ] No errors in DevTools console

---

## 🔧 Troubleshooting

### "Element IDs not working?"

1. Make sure you're adding **to actual elements** (not text nodes)
2. Use **exact ID names** from WEBFLOW-ELEMENT-IDS.md
3. IDs are case-sensitive: `#MyId` ≠ `#myid`
4. Use **Settings panel** to set IDs (top right ⚙️)
5. Check with browser DevTools: `document.querySelector('#your-id')`

### "Custom Code not executing?"

1. Verify Custom Code is in **Page Settings** (not in page elements)
2. Use `<script src="...">` not inline JavaScript
3. Check browser console for errors
4. Hard refresh page (`Cmd+Shift+R` / `Ctrl+Shift+R`)
5. Make sure scripts are deployed to `/scripts/` path

### "Pages not showing up?"

1. Hard refresh Designer: `Cmd+Shift+R` or `Ctrl+Shift+R`
2. Close and reopen Webflow Designer
3. Check for archived pages (scroll down in Pages panel)
4. Check slug doesn't have typos

---

## 📚 Related Documentation

**Must Read:**
- [`docs/WEBFLOW-MANUAL.md`](docs/WEBFLOW-MANUAL.md) – Detailed manual setup
- [`docs/WEBFLOW-ELEMENT-IDS.md`](docs/WEBFLOW-ELEMENT-IDS.md) – Required IDs per page

**Design & Content:**
- [`docs/DESIGN.md`](docs/DESIGN.md) – Design system (colors, typography)
- [`docs/COPY.md`](docs/COPY.md) – Content templates

**Technical:**
- [`docs/WEBFLOW-SITEMAP.md`](docs/WEBFLOW-SITEMAP.md) – Site structure
- [`docs/WEBFLOW-QA-CHECKLIST.md`](docs/WEBFLOW-QA-CHECKLIST.md) – Testing checklist

---

## 🚀 After Pages Are Created

```bash
# Pull latest changes (if working locally)
git pull origin main

# Validate secrets
npm run secrets:validate

# Test API connections
npm run health:full

# Deploy backend
npm run deploy:backend

# Test Webflow site
# Open in browser and check DevTools console
```

---

## ⏱️ Time Breakdown

| Task | Time |
|------|------|
| Open Designer | 2 min |
| Create 6 pages | 5 min |
| Add element IDs | 15 min |
| Add Custom Code | 10 min |
| Design pages | 20+ min |
| Publish | 1 min |
| **Total** | **53+ min** |

---

## 🎯 Success Criteria

✅ **Done when:**
- All 6 pages visible in Webflow Designer
- Element IDs set correctly
- Custom Code added to page settings
- Pages designed with content
- Site published
- Browser console shows `[Klarpakke]` messages
- No JavaScript errors in console

---

## 👥 Need Help?

**Questions?**
- Check: [`docs/WEBFLOW-MANUAL.md`](docs/WEBFLOW-MANUAL.md)
- Open: [GitHub Issue](https://github.com/tombomann/klarpakke/issues)

**Report bugs:**
Include:
- Page name
- Element ID that's not working
- Browser console error (if any)
- Screenshot of Webflow Designer

---

**Ready? Open Webflow Designer and start creating! 🎨**

🔗 **Go to Designer:** https://webflow.com/dashboard/sites/klarpakke/designer
