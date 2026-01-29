# 🎨 Webflow Manual Setup - Quick Guide (25 min)

**Status:** Your API token has limited Designer access. Use this guide to create pages manually.

**Time:** ~25 minutes total

**After this:** All automation will work! ✨

---

## 📋 Setup Checklist

- [ ] Step 1: Open Webflow Designer (2 min)
- [ ] Step 2: Create 6 missing pages (20 min)
- [ ] Step 3: Re-run npm script (1 min)
- [ ] Step 4: Deploy (2 min)

---

## Step 1️⃣ Open Webflow Designer

1. Go to **[webflow.com](https://webflow.com)**
2. Click **Klarpakke** project
3. Click **Designer** button (top-right)
4. Wait for it to load...

✅ You should see the **Pricing** page already exists in the Pages panel (left sidebar)

---

## Step 2️⃣ Create 6 Missing Pages

### Page 1: Home (/) - 3 minutes

**Create the page:**
- Right-click **Pages** panel → **New Page**
- Name: `Home`
- Slug: `index`
- Click **Create**

**Add content:**
Copy-paste this into the page body:

```html
<section id="hero" style="padding: 80px 20px; text-align: center;">
  <h1>Klarpakke</h1>
  <p>Din AI-drevne kryptotradingassistent</p>
  <div style="margin-top: 30px;">
    <button id="cta-primary" style="padding: 12px 24px; margin: 5px; background: #32a896; color: white; border: none; border-radius: 8px; cursor: pointer; font-size: 16px;">Start Demo</button>
    <button id="cta-demo" style="padding: 12px 24px; margin: 5px; background: #ddd; color: #333; border: none; border-radius: 8px; cursor: pointer; font-size: 16px;">Learn More</button>
  </div>
</section>

<section id="features" style="padding: 80px 20px; background: #f5f5f5;">
  <h2 style="text-align: center;">Features</h2>
  <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 30px; max-width: 1200px; margin: 30px auto;">
    <div style="padding: 20px; background: white; border-radius: 8px;">
      <h3>AI Signals</h3>
      <p>Real-time trading signals powered by AI</p>
    </div>
    <div style="padding: 20px; background: white; border-radius: 8px;">
      <h3>Risk Calculator</h3>
      <p>Calculate position sizes and risk</p>
    </div>
    <div style="padding: 20px; background: white; border-radius: 8px;">
      <h3>Portfolio Tracking</h3>
      <p>Track all your positions in one place</p>
    </div>
  </div>
</section>

<footer id="footer" style="padding: 40px 20px; background: #333; color: white; text-align: center;">
  <p>&copy; 2026 Klarpakke. All rights reserved.</p>
</footer>
```

**Add custom code:**
1. Click **Page Settings** (⚙️ gear icon, top-right)
2. Scroll to **Custom Code**
3. Paste in **Head code:**
```html
<script src="/scripts/webflow-loader.js"></script>
<title>Klarpakke - Trygg Krypto-Trading med AI</title>
<meta name="description" content="Din AI-drevne kryptotradingassistent for nordiske investorer.">
```
4. Click **Save**

✅ **Page 1 complete!**

---

### Page 2: Dashboard (/app/dashboard) - 3 minutes

**Create the page:**
- Right-click **Pages** → **New Page**
- Name: `Dashboard`
- Slug: `app/dashboard`
- Click **Create**

**Add content:**

```html
<div id="app-root" style="display: flex; height: 100vh;">
  <nav id="sidebar" style="width: 250px; background: #333; color: white; padding: 20px;">
    <div style="font-size: 20px; font-weight: bold; margin-bottom: 30px;">Klarpakke</div>
    <ul style="list-style: none; padding: 0;">
      <li><a href="/app/dashboard" style="color: #32a896; text-decoration: none; display: block; padding: 10px 0;">📊 Dashboard</a></li>
      <li><a href="/app/settings" style="color: white; text-decoration: none; display: block; padding: 10px 0;">⚙️ Settings</a></li>
    </ul>
    <button id="btn-logout" style="margin-top: 30px; width: 100%; padding: 10px; background: #c00; color: white; border: none; border-radius: 4px; cursor: pointer;">🚪 Logout</button>
  </nav>
  
  <main id="main-content" style="flex: 1; padding: 40px;">
    <h1>Trading Signals</h1>
    <div id="signals-feed" style="margin: 20px 0; padding: 20px; background: #f5f5f5; border-radius: 8px; min-height: 300px;">
      <p style="color: #999;">Loading signals...</p>
    </div>
    
    <div id="stats-panel" style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px;">
      <div style="padding: 20px; background: #f0f8f6; border-radius: 8px;">
        <h3 style="margin: 0 0 10px 0;">Total Signals</h3>
        <p id="stat-total" style="font-size: 24px; font-weight: bold; margin: 0;">0</p>
      </div>
      <div style="padding: 20px; background: #f0f8f6; border-radius: 8px;">
        <h3 style="margin: 0 0 10px 0;">Winning</h3>
        <p style="font-size: 24px; font-weight: bold; margin: 0; color: #32a896;">0</p>
      </div>
      <div style="padding: 20px; background: #f0f8f6; border-radius: 8px;">
        <h3 style="margin: 0 0 10px 0;">Losing</h3>
        <p style="font-size: 24px; font-weight: bold; margin: 0; color: #c00;">0</p>
      </div>
    </div>
  </main>
</div>
```

**Add custom code:**
1. **Page Settings** → **Custom Code**
2. **Head code:**
```html
<script src="/scripts/webflow-loader.js"></script>
<title>Dashboard - Klarpakke</title>
```
3. **Footer code:**
```html
<script src="/scripts/klarpakke-site.js"></script>
```
4. **Save**

✅ **Page 2 complete!**

---

### Page 3: Kalkulator (/app/kalkulator) - 3 minutes

**Create the page:**
- Right-click **Pages** → **New Page**
- Name: `Kalkulator`
- Slug: `app/kalkulator`
- Click **Create**

**Add content:**

```html
<div id="calculator-root" style="max-width: 600px; margin: 80px auto; padding: 40px;">
  <h1 style="text-align: center;">Risiko-Kalkulator</h1>
  
  <form id="calculator-form" style="background: #f5f5f5; padding: 30px; border-radius: 8px;">
    <div style="margin-bottom: 20px;">
      <label for="calc-input-1" style="display: block; margin-bottom: 8px; font-weight: bold;">Beløp (NOK)</label>
      <input 
        id="calc-input-1" 
        type="number" 
        placeholder="10000"
        min="0"
        style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 16px; box-sizing: border-box;"
      >
    </div>
    
    <div style="margin-bottom: 20px;">
      <label for="calc-input-2" style="display: block; margin-bottom: 8px; font-weight: bold;">Rente (%)</label>
      <input 
        id="calc-input-2" 
        type="number" 
        placeholder="5"
        min="0"
        step="0.1"
        style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; font-size: 16px; box-sizing: border-box;"
      >
    </div>
    
    <div style="display: flex; gap: 10px;">
      <button id="calc-submit" type="button" style="flex: 1; padding: 12px; background: #32a896; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; font-weight: bold;">
        Beregn
      </button>
      <button id="calc-reset" type="button" style="flex: 1; padding: 12px; background: #ddd; color: #333; border: none; border-radius: 4px; cursor: pointer; font-size: 16px;">
        Reset
      </button>
    </div>
  </form>
  
  <div id="calc-result" style="margin-top: 30px; padding: 20px; background: #f0f8f6; border-radius: 8px; display: none;">
    <h2 style="margin: 0 0 10px 0;">Resultat</h2>
    <p id="calc-result-text" style="margin: 0; font-size: 18px; color: #32a896; font-weight: bold;"></p>
  </div>
</div>
```

**Add custom code:**
1. **Page Settings** → **Custom Code**
2. **Head code:**
```html
<script src="/scripts/webflow-loader.js"></script>
<title>Risiko-Kalkulator - Klarpakke</title>
```
3. **Footer code:**
```html
<script src="/scripts/calculator.js"></script>
```
4. **Save**

✅ **Page 3 complete!**

---

### Page 4: Settings (/app/settings) - 3 minutes

**Create the page:**
- Right-click **Pages** → **New Page**
- Name: `Settings`
- Slug: `app/settings`
- Click **Create**

**Add content:**

```html
<div id="app-root" style="max-width: 800px; margin: 40px auto; padding: 40px;">
  <h1>Innstillinger</h1>
  
  <form id="form-settings" style="background: #f5f5f5; padding: 30px; border-radius: 8px;">
    <fieldset style="border: none; margin-bottom: 30px; padding: 0;">
      <legend style="font-size: 18px; font-weight: bold; margin-bottom: 15px;">API Nøkler</legend>
      <div style="margin-bottom: 15px;">
        <label for="form-apikey" style="display: block; margin-bottom: 8px;">Webflow API Token</label>
        <input 
          id="form-apikey" 
          name="api_key" 
          type="password"
          placeholder="••••••••"
          style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;"
        >
        <small style="display: block; margin-top: 5px; color: #666;">Ditt eksisterende nøkkel vises ikke av sikkerhetsgrunner</small>
      </div>
    </fieldset>
    
    <fieldset style="border: none; margin-bottom: 30px; padding: 0;">
      <legend style="font-size: 18px; font-weight: bold; margin-bottom: 15px;">Notifikasjoner</legend>
      <div style="margin-bottom: 10px;">
        <label style="display: flex; align-items: center;">
          <input 
            type="checkbox" 
            id="notify-email" 
            name="notify_email"
            style="margin-right: 10px; width: 18px; height: 18px; cursor: pointer;"
          >
          <span>E-postvarslinger</span>
        </label>
      </div>
      <div>
        <label style="display: flex; align-items: center;">
          <input 
            type="checkbox" 
            id="notify-push" 
            name="notify_push"
            style="margin-right: 10px; width: 18px; height: 18px; cursor: pointer;"
          >
          <span>Push-varslinger</span>
        </label>
      </div>
    </fieldset>
    
    <div style="display: flex; gap: 10px;">
      <button type="submit" style="flex: 1; padding: 12px; background: #32a896; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; font-weight: bold;">
        Lagre
      </button>
      <button type="button" id="btn-logout-all" style="flex: 1; padding: 12px; background: #c00; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px;">
        Logg ut fra alle enheter
      </button>
    </div>
  </form>
</div>
```

**Add custom code:**
1. **Page Settings** → **Custom Code**
2. **Head code:**
```html
<script src="/scripts/webflow-loader.js"></script>
<title>Innstillinger - Klarpakke</title>
```
3. **Save**

✅ **Page 4 complete!**

---

### Page 5: Login (/login) - 3 minutes

**Create the page:**
- Right-click **Pages** → **New Page**
- Name: `Login`
- Slug: `login`
- Click **Create**

**Add content:**

```html
<div style="display: flex; align-items: center; justify-content: center; min-height: 100vh; background: #f5f5f5;">
  <div style="background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 100%; max-width: 400px;">
    <h1 style="text-align: center; margin-bottom: 30px;">Logg Inn</h1>
    
    <form id="form-login" style="margin-bottom: 20px;">
      <div style="margin-bottom: 20px;">
        <label for="form-email" style="display: block; margin-bottom: 8px; font-weight: bold;">E-post</label>
        <input 
          id="form-email" 
          name="email" 
          type="email"
          placeholder="din@epost.no"
          required
          style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;"
        >
      </div>
      
      <div style="margin-bottom: 20px;">
        <label for="form-password" style="display: block; margin-bottom: 8px; font-weight: bold;">Passord</label>
        <input 
          id="form-password" 
          name="password" 
          type="password"
          placeholder="••••••••"
          required
          style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;"
        >
      </div>
      
      <button type="submit" id="btn-login" style="width: 100%; padding: 12px; background: #32a896; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; font-weight: bold;">
        Logg Inn
      </button>
    </form>
    
    <p style="text-align: center; margin: 15px 0;">
      Har du ikke konto? <a href="/signup" style="color: #32a896; text-decoration: none;">Registrer deg</a>
    </p>
    <p style="text-align: center;">
      <a href="#" style="color: #32a896; text-decoration: none;">Glemt passord?</a>
    </p>
  </div>
</div>
```

**Add custom code:**
1. **Page Settings** → **Custom Code**
2. **Head code:**
```html
<script src="/scripts/webflow-loader.js"></script>
<title>Logg Inn - Klarpakke</title>
```
3. **Footer code:**
```html
<script src="/scripts/supabase-auth.js"></script>
```
4. **Save**

✅ **Page 5 complete!**

---

### Page 6: Signup (/signup) - 3 minutes

**Create the page:**
- Right-click **Pages** → **New Page**
- Name: `Sign Up`
- Slug: `signup`
- Click **Create**

**Add content:**

```html
<div style="display: flex; align-items: center; justify-content: center; min-height: 100vh; background: #f5f5f5;">
  <div style="background: white; padding: 40px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); width: 100%; max-width: 400px;">
    <h1 style="text-align: center; margin-bottom: 30px;">Registrer Deg</h1>
    
    <form id="form-signup" style="margin-bottom: 20px;">
      <div style="margin-bottom: 20px;">
        <label for="form-email" style="display: block; margin-bottom: 8px; font-weight: bold;">E-post</label>
        <input 
          id="form-email" 
          name="email" 
          type="email"
          placeholder="din@epost.no"
          required
          style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;"
        >
      </div>
      
      <div style="margin-bottom: 20px;">
        <label for="form-password" style="display: block; margin-bottom: 8px; font-weight: bold;">Passord</label>
        <input 
          id="form-password" 
          name="password" 
          type="password"
          placeholder="Minst 8 tegn"
          minlength="8"
          required
          style="width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box;"
        >
        <div id="password-strength" style="margin-top: 8px; font-size: 12px; color: #666;"></div>
      </div>
      
      <div style="margin-bottom: 20px;">
        <label style="display: flex; align-items: flex-start;">
          <input type="checkbox" required style="margin-right: 10px; margin-top: 4px; cursor: pointer;">
          <span>Jeg godtar <a href="#" style="color: #32a896; text-decoration: none;">vilkårene</a></span>
        </label>
      </div>
      
      <button type="submit" id="btn-signup" style="width: 100%; padding: 12px; background: #32a896; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 16px; font-weight: bold;">
        Registrer
      </button>
    </form>
    
    <p style="text-align: center;">
      Allerede registrert? <a href="/login" style="color: #32a896; text-decoration: none;">Logg inn</a>
    </p>
  </div>
</div>
```

**Add custom code:**
1. **Page Settings** → **Custom Code**
2. **Head code:**
```html
<script src="/scripts/webflow-loader.js"></script>
<title>Registrer Deg - Klarpakke</title>
```
3. **Footer code:**
```html
<script src="/scripts/supabase-auth.js"></script>
```
4. **Save**

✅ **Page 6 complete!**

---

## Step 3️⃣ Re-run the Build Script

Now that all pages exist, go back to terminal:

```bash
npm run ai:webflow-full
```

This time it should:
- ✅ Find all 7 pages
- ✅ Skip Pricing (already has content)
- ✅ Inject AI content into the other pages
- ✅ Generate IDs for buttons/forms
- ✅ Optimize for SEO

---

## Step 4️⃣ Deploy

```bash
npm run deploy:prod
```

This will:
- ✅ Validate all systems
- ✅ Publish your Webflow site
- ✅ Set up Supabase
- ✅ Configure GitHub Actions

---

## ✅ Done!

Your Klarpakke website is now **production-ready**! 🎉

### What just happened:
1. Created 6 pages manually (25 min)
2. Scripts auto-injected AI content
3. All automation now works
4. Published to production

---

## 🐛 Troubleshooting

### "Script not loading" error
**Problem:** JavaScript console shows errors
**Solution:** 
1. Refresh the page
2. Check browser console (F12)
3. Verify script URLs are correct

### "Page not found" in CLI
**Problem:** Script says page doesn't exist
**Solution:** 
1. Wait 30 seconds after creating page
2. Publish changes in Webflow
3. Run `npm run health:full` to validate

### Need to edit a page later?
1. Go to Webflow Designer
2. Edit the page
3. Run `npm run ai:webflow-full` again
4. It will skip existing pages, update content

---

## 📞 Support

Check these files if something goes wrong:
- `docs/WEBFLOW-MCP-FIXED.md` - API integration details
- `docs/ONE-CLICK-DEPLOY.md` - Full deployment guide
- `.github/workflows/` - Automated processes

**That's it! You're all set.** 🚀
