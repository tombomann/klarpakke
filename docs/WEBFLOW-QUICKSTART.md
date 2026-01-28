# 🚀 Webflow Quick Start (2 Minutes)

## Step 1: Generate Webflow Code (30 seconds)

```bash
cd ~/klarpakke

# For staging:
npm run gen:webflow-staging

# For production:
npm run gen:webflow-production
```

**✅ Code is automatically copied to clipboard!**

---

## Step 2: Paste in Webflow (1 minute)

1. **Open Webflow:**
   - Go to: https://webflow.com/dashboard/sites/klarpakke-c65071/designer
   - Or click: **Open in Webflow** button

2. **Open Project Settings:**
   - Click ⚙️ (Settings icon, top left)
   - Navigate to: **Custom Code**

3. **Paste in Footer Code:**
   - Scroll down to: **Footer Code (Before </body>)**
   - Clear any existing code
   - Paste (Cmd+V)
   - Click **Save Changes**

---

## Step 3: Publish (30 seconds)

1. Click **Publish** (top right corner)
2. Select domain:
   - **Staging:** `klarpakke-c65071.webflow.io`
   - **Production:** `klarpakke.no`
3. Click **Publish to selected domains**

---

## Step 4: Test (1 minute)

### Quick Console Test

1. Open your published site
2. Open DevTools Console (F12 or Cmd+Option+I)
3. Look for:
   ```
   [Klarpakke ℹ️] Booting on route: /
   [Klarpakke ℹ️] Config loaded: {...}
   ```

### Test Each Page

**Kalkulator:** `/kalkulator`
- [ ] Slider moves smoothly
- [ ] Table updates with values
- [ ] No console errors

**Pricing:** `/pricing`
- [ ] All 4 plan cards visible
- [ ] Buttons work (check Console for routing)

**Dashboard:** `/app/dashboard`
- [ ] Page loads without errors
- [ ] Shows "Laster signaler..." or empty state

---

## Troubleshooting

### "Missing SUPABASE_URL in .env"

```bash
# Make sure .env exists:
cp .env.example .env

# Get credentials from Supabase:
# https://supabase.com/dashboard/project/_/settings/api

# Fill in:
SUPABASE_URL=https://xyzabc123.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
```

### "Script not loading"

**Check CDN URL in generated code:**
```html
<!-- ✅ Correct (no /dist/) -->
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/klarpakke-site.js"></script>

<!-- ❌ Wrong -->
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/dist/klarpakke-site.js"></script>
```

### "Code shows as text on page"

**Problem:** Code was pasted in wrong location  
**Solution:**
1. Go to: **Project Settings → Custom Code**
2. Paste in: **Footer Code** section (NOT Head Code)
3. Make sure `<script>` tags are present

### "Old code still running"

**Solution:** Hard refresh
- Chrome/Safari: Cmd+Shift+R
- Firefox: Ctrl+Shift+R

---

## What Gets Injected

```html
<!-- Klarpakke Custom Code for staging -->
<!-- Generated: 2026-01-28 15:30:00 -->

<script>
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: "https://xyzabc123.supabase.co",
    supabaseAnonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    debug: true  // false in production
  };
</script>
<script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/klarpakke-site.js"></script>
```

---

## Security Checklist

- ✅ Using `SUPABASE_ANON_KEY` (safe for frontend)
- ❌ Never use `SUPABASE_SECRET_KEY` in Webflow
- ✅ `.env` is in `.gitignore`
- ✅ Debug mode OFF in production

---

## Next Steps After Setup

1. **Build Required DOM Elements**
   - See: `docs/PRODUCTION-PLAN.md` → "Element IDs Required"
   - Kalkulator needs: `#calc-start`, `#calc-crypto-percent`, etc.
   - Dashboard needs: `#signals-container`
   - Settings needs: `#save-settings`, `#plan-select`, etc.

2. **Add Copy from COPY.md**
   - All text content is ready in `docs/COPY.md`
   - Apply tone and microcopy

3. **Apply Design from DESIGN.md**
   - Colors, typography, trafikklys system

4. **Test All User Flows**
   - New user: Landing → Opplæring → Pricing → Dashboard
   - Existing user: Dashboard → Approve signal → Settings

---

## Links

- **Webflow Dashboard:** https://webflow.com/dashboard/sites/klarpakke-c65071
- **Webflow Designer:** https://webflow.com/dashboard/sites/klarpakke-c65071/designer
- **Supabase Dashboard:** https://supabase.com/dashboard
- **GitHub Repo:** https://github.com/tombomann/klarpakke

---

**Total Time:** ~2-3 minutes from code generation to live site! 🎉
