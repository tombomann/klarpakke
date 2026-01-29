# 🎨 Webflow Automated Setup Guide

**HELT AUTOMATISK WEBFLOW CMS OPPSETT** – Dette dokumentet viser hvordan du kan sette opp hele Webflow CMS-strukturen automatisk via GitHub Actions og npm scripts.

---

## ✨ Hva Som Automatiseres

✅ **CMS Collections** – Automatisk opprettelse av alle nødvendige collections  
✅ **Data Sync** – Supabase → Webflow synkronisering hver dag  
✅ **Custom Code** – Generering av ferdig HTML/CSS/JS snippets  
✅ **Validation** – Automatisk sjekk av setup-status  
✅ **Page Templates** – Klar-til-bruk HTML for alle sider  

---

## 🚀 Quick Start (3 Steg)

### Steg 1: Kjør Automatisk Setup

```bash
cd ~/klarpakke
git pull origin main

# Installer dependencies
npm install

# Valider nåværende setup
npm run webflow:validate

# Opprett manglende collections automatisk
npm run webflow:auto-setup

# Generer custom code snippets
npm run webflow:generate-snippets
```

### Steg 2: Kopier Generated Snippets til Webflow

Etter `npm run webflow:generate-snippets` finner du alle snippets i:

```
web/snippets/
  ├── dashboard-page-head.html
  ├── dashboard-page-body.html
  ├── settings-page-body.html
  ├── calculator-page-body.html
  └── footer-loader-production.html
```

**📖 Webflow Designer:**

1. Åpne hver side (Dashboard, Settings, Calculator)
2. **Page Settings → Custom Code → Head** – Lim inn `*-head.html`
3. **Add HTML Embed element** – Lim inn `*-body.html`
4. **Project Settings → Custom Code → Footer** – Lim inn `footer-loader-production.html`

### Steg 3: Publiser

```bash
# Test CMS sync
npm run webflow:sync

# Publiser i Webflow Designer
# Klikk "Publish" knappen øvre høyre hjørne
```

---

## 🤖 GitHub Actions Automation

### Workflow: Webflow CMS Auto-Setup

**Fil:** `.github/workflows/webflow-cms-auto-setup.yml`

**Trigger:** Manuell (fra Actions tab)

**Operasjoner:**
- `validate` – Sjekk nåværende setup
- `create-collections` – Opprett manglende collections
- `sync-data` – Sync data fra Supabase
- `full-setup` – Kjør alt i rekkefølge

**Kjør workflow:**

1. Gå til [GitHub Actions](https://github.com/tombomann/klarpakke/actions)
2. Velg **🎨 Webflow CMS Auto-Setup**
3. Klikk **Run workflow**
4. Velg operation: `full-setup`
5. Klikk **Run workflow** (grønn knapp)

**Artifacts:**  
Etter kjøring kan du laste ned:
- `webflow-setup-report.json` – Detailed results
- `web/snippets/*.html` – All custom code

---

## 📚 NPM Scripts Oversikt

| Script | Beskrivelse | Bruk |
|--------|-------------|------|
| `npm run webflow:validate` | Validerer Webflow setup | Kjør før alt annet |
| `npm run webflow:auto-setup` | Oppretter manglende collections | Kjør 1 gang |
| `npm run webflow:generate-snippets` | Genererer HTML/CSS/JS snippets | Hver gang du oppdaterer design |
| `npm run webflow:sync` | Manuell CMS sync | Test data sync |

---

## 📦 CMS Collections (Auto-Created)

### 1. Signals Collection

**Fields:**
- `name` (PlainText) – Signal name
- `symbol` (PlainText) – Crypto symbol (BTC, ETH, etc.)
- `direction` (Option) – BUY or SELL
- `confidence` (Number) – AI confidence (0-100)
- `reason` (RichText) – AI reasoning
- `status` (Option) – pending, approved, rejected
- `ai-model` (PlainText) – Model used

**Auto-sync:** Yes (daily at 06:00 UTC)

### 2. Testimonials Collection

**Fields:**
- `name` (PlainText) – Customer name
- `quote` (RichText) – Testimonial text
- `role` (PlainText) – Customer role/title
- `avatar` (ImageRef) – Profile picture
- `rating` (Number) – Star rating (1-5)

**Usage:** Landing page testimonials section

### 3. FAQ Items Collection

**Fields:**
- `question` (PlainText) – FAQ question
- `answer` (RichText) – FAQ answer
- `category` (PlainText) – Category (General, Trading, etc.)
- `order` (Number) – Display order

**Usage:** FAQ page / accordion

---

## 📝 Page Templates

### Dashboard (`/app/dashboard`)

**Required Element IDs:**
```html
#signals-container  <!-- Main container for signals list -->
#kp-toast           <!-- Toast notifications -->
```

**Optional Filter Buttons:**
```html
#filter-all         <!-- Show all signals -->
#filter-buy         <!-- Show only BUY signals -->
#filter-sell        <!-- Show only SELL signals -->
```

**Custom Code:**
- **HEAD:** `dashboard-page-head.html` (CSS styling)
- **BODY:** `dashboard-page-body.html` (HTML structure)

**How it works:**
1. JavaScript fetches signals from Supabase
2. Renders signal cards dynamically
3. Approve/Reject buttons call Supabase Edge Functions
4. Cards remove themselves on action

---

### Settings (`/app/settings`)

**Required Element IDs:**
```html
#settings-form      <!-- Form wrapper -->
#plan-select        <!-- Plan dropdown -->
#compound-toggle    <!-- Compounding checkbox -->
#save-settings      <!-- Save button -->
```

**Custom Code:**
- **BODY:** `settings-page-body.html`

**How it works:**
1. User selects plan + compounding preference
2. JavaScript saves to Supabase (or localStorage if offline)
3. Toast confirmation

---

### Calculator (`/kalkulator`)

**Required Element IDs:**
```html
#calc-start              <!-- Starting amount input -->
#calc-crypto-percent     <!-- Crypto allocation slider -->
#calc-plan               <!-- Plan selector -->
#calc-result-table       <!-- Results container -->
#crypto-percent-label    <!-- Optional: % display -->
```

**Custom Code:**
- **BODY:** `calculator-page-body.html`

**How it works:**
1. User inputs starting amount + risk preferences
2. `web/calculator.js` calculates potential outcomes
3. Results table shows projections per plan

---

### Pricing (`/pricing`)

**Required Attributes:**
```html
<button data-plan="paper">Select Paper Plan</button>
<button data-plan="safe">Select Safe Plan</button>
<button data-plan="pro">Select Pro Plan</button>
<button data-plan="extrem">Select Ekstrem Plan</button>
```

**How it works:**
1. User clicks plan button
2. JavaScript reads `data-plan` attribute
3. Redirects to `/app/settings?plan={plan}` (or `/opplaering` for extrem)

---

## 🔧 Troubleshooting

### Collections Not Creating

**Problem:** `npm run webflow:auto-setup` fails

**Solutions:**
1. Check GitHub Secrets are set:
   ```bash
   WEBFLOW_API_TOKEN
   WEBFLOW_SITE_ID
   ```
2. Verify API token has **CMS write permissions**
3. Check rate limits (Webflow API: 60 req/min)

### Data Not Syncing

**Problem:** CMS items not updating

**Solutions:**
1. Run manual sync: `npm run webflow:sync`
2. Check logs: `tail -f /var/log/klarpakke-sync.log`
3. Validate secrets: `npm run secrets:validate`
4. Check Supabase has data:
   ```sql
   SELECT COUNT(*) FROM signals WHERE status = 'approved';
   ```

### JavaScript Not Loading

**Problem:** Pages load but features don't work

**Solutions:**
1. Open browser DevTools → Console
2. Look for `[Klarpakke]` log messages
3. Check Network tab for failed script loads
4. Verify footer loader is in **Project Settings → Footer** (NOT page settings)
5. Hard refresh: `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)

### Missing Element IDs

**Problem:** Console shows "Missing required #element-id"

**Solutions:**
1. Enable debug mode: `localStorage.setItem('klarpakke_debug', '1')`
2. Reload page – console will show all missing elements
3. Add missing IDs in Webflow Designer:
   - Select element
   - Settings panel → Element Settings → ID field
   - Type exact ID (e.g., `signals-container`)

---

## 🚨 Important Notes

### ⛔ DO NOT

- **NEVER** paste JavaScript directly in Page Settings → Custom Code
- **NEVER** manually create CMS items that auto-sync will create
- **NEVER** expose `SUPABASE_SERVICE_ROLE_KEY` in frontend code

### ✅ DO

- **ALWAYS** use Project Settings → Footer for `footer-loader-production.html`
- **ALWAYS** test in staging before production
- **ALWAYS** use element IDs (not classes) for JavaScript targets
- **ALWAYS** run `npm run webflow:validate` before deploy

---

## 📊 Monitoring

### GitHub Actions Dashboard

**Daily CMS Sync:**  
https://github.com/tombomann/klarpakke/actions/workflows/sync-cms-daily.yml

**Webflow Setup:**  
https://github.com/tombomann/klarpakke/actions/workflows/webflow-cms-auto-setup.yml

### Logs

```bash
# View sync logs
tail -f /var/log/klarpakke-sync.log

# View setup logs
cat webflow-setup-report.json
```

### Health Checks

```bash
# Full system check
npm run health:full

# Webflow-specific
npm run webflow:validate
```

---

## 📚 Further Reading

- [Webflow Manual Guide](./WEBFLOW-MANUAL.md) – How to avoid common mistakes
- [Webflow Element IDs](./WEBFLOW-ELEMENT-IDS.md) – Complete ID reference
- [Design System](./DESIGN.md) – Colors, typography, components
- [Copy Guide](./COPY.md) – All text content

---

## ✅ Checklist

**Before Production Deploy:**

- [ ] Run `npm run webflow:validate` – No errors
- [ ] Run `npm run webflow:auto-setup` – All collections created
- [ ] Run `npm run webflow:generate-snippets` – Snippets generated
- [ ] All snippets pasted in Webflow Designer
- [ ] Footer loader in Project Settings → Footer
- [ ] Test all pages in Webflow Preview
- [ ] Run `npm run webflow:sync` – Data appears in CMS
- [ ] Hard refresh + check browser console – No errors
- [ ] Test on mobile/tablet/desktop
- [ ] Publish to staging first
- [ ] QA on staging URL
- [ ] Deploy to production

---

**Last Updated:** 2026-01-29
