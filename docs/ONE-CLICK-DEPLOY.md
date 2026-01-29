# 🚀 Klarpakke One-Click Deploy

**Full automation**: From zero to deployed in 4 steps (mostly automatic).

---

## Step 1: Initial Setup (Bootstrap)

```bash
# Clone repo or navigate to existing klarpakke directory
cd ~/klarpakke

# Run bootstrap script
chmod +x scripts/bootstrap-mac-m1.sh
./scripts/bootstrap-mac-m1.sh
```

### What bootstrap does:
- ✅ Checks Node 18+, npm, Supabase CLI, jq
- ✅ Runs `npm ci` + `npm run build:web`
- ✅ Creates `.env.local` (prompts you to fill secrets)
- ✅ Runs `npm run health:full` to verify setup
- ✅ Optionally links to Supabase cloud or starts local

**⏱️ Time:** ~5 minutes (mostly waiting for downloads)

---

## Step 2: Install Designer Extension

Wait for GitHub Actions to build the extension:

1. Go to: https://github.com/tombomann/klarpakke/releases
2. Download latest `klarpakke-designer.js` (v0.1.0+)
3. In Webflow Dashboard:
   - Click **Custom Apps** (left sidebar)
   - Click **+** (Add Custom App)
   - Choose **Get from URL**
   - Paste the URL to the released file or upload the `.js` file
   - Install

**Note:** First run, the CI might be building. Check Actions tab: https://github.com/tombomann/klarpakke/actions/workflows/designer-extension-build.yml

**⏱️ Time:** ~2 minutes

---

## Step 3: Deploy Everything (Full Stack)

Go to GitHub Actions and run the "One-Click" workflow:

1. https://github.com/tombomann/klarpakke/actions
2. Find workflow: **🧨 One-Click (Full Stack)**
3. Click **Run workflow**
4. Select:
   - **environment:** `staging` (first time)
   - **use_ai:** `true` (for Perplexity content generation)
   - **pages:** `all`
   - **skip_webflow:** `false` (we want to deploy)
5. Click **Run workflow**

### What the workflow does:
- ✅ Build web bundles
- ✅ Deploy Supabase migrations + functions
- ✅ Generate AI content (IDs, SEO) via Perplexity
- ✅ Deploy custom code to Webflow
- ✅ Publish Webflow site
- ✅ Sync Supabase data → Webflow CMS
- ✅ Run health check

**⏱️ Time:** ~10–15 minutes

---

## Step 4: Create Pages in Webflow Designer

Now that the site is published, create the pages via Designer extension:

1. Open Webflow Designer: https://webflow.com/dashboard/sites/klarpakke-{your-id}/designer
2. Click **Extensions** (right panel)
3. Find **Klarpakke**
4. Click **✨ Create Klarpakke Pages**
   - This creates: index, pricing, /app/dashboard, /app/kalkulator, /app/settings, login, signup
   - If pages already exist, they're skipped (idempotent)
5. Click **✅ Verify Element IDs**
   - This checks that all required element IDs exist
   - If any are missing, the report shows which page/ID

**⏱️ Time:** ~1 minute

---

## Step 5: Test & Publish

1. In Designer, open each page and verify they look correct:
   - `/` (landing/home)
   - `/pricing`
   - `/app/dashboard`
   - `/app/kalkulator`
   - `/app/settings`
   - `/login`
   - `/signup`

2. Make any design tweaks you want

3. Click **Publish** (top right) to publish to production

4. Test in browser:
   - Open your live site
   - Open DevTools Console (F12)
   - Look for: `[Klarpakke] Config loaded`
   - Navigate to different pages, test calculator, etc.

**⏱️ Time:** Varies (depends on customization)

---

## ✅ You're Done!

**Total time:** ~30 minutes (first time)
**Subsequent deploys:** ~15 minutes (skip steps 1–2)

---

## Daily Development

After initial setup, you can:

### Update frontend code
```bash
git add .
git commit -m "feat: new feature"
git push origin main
```
→ Automatic CDN update within 12 hours

### Update Supabase
```bash
supabase link --project-ref <your-project-ref>
supabase db push
```
→ Migrations deployed automatically

### Update design in Webflow
- Designer → Make changes → Publish
→ Live immediately

### Re-deploy full stack
- GitHub Actions → Run "One-Click" workflow
→ Everything syncs

---

## Troubleshooting

### Problem: Bootstrap fails on dependencies
**Solution:** Install missing tool (Supabase CLI, jq):
```bash
brew install supabase jq
```

### Problem: "Designer Extension not loading"
**Solution:** Check Webflow Dashboard > Custom Apps > Klarpakke > check for errors
- If URL is invalid, re-paste from Releases
- If JS is broken, check GitHub Actions build: https://github.com/tombomann/klarpakke/actions

### Problem: "Pages not created / No elements found"
**Solution:**
1. Check that Webflow site is set up in `.env.local` (WEBFLOW_SITE_ID, API token)
2. Verify in Webflow Dashboard > Site Settings > Custom Code that the loader is present
3. Run "Verify Element IDs" to see exact report

### Problem: "Health check failed"
**Solution:** Check the GitHub Actions log for the specific error
- Usually missing Supabase connectivity or wrong secrets
- Update `.env.local` and run `npm run health:full` locally

### Problem: "Script loads but nothing happens"
**Solution:**
1. Check Console (F12) for `[Klarpakke]` logs
2. Check Network tab: verify CDN files load successfully
3. If 404 on CDN, CDN cache may be stale:
   ```
   https://www.jsdelivr.com/tools/purge
   ```
4. Force refresh: `Cmd+Shift+R`

---

## Secrets Reference

Required secrets in GitHub (Settings > Secrets and Variables > Actions):

| Secret | Example | Where to get |
|--------|---------|---------------|
| `SUPABASE_ACCESS_TOKEN` | `sbp_1a2b3c...` | Supabase Dashboard > Settings > API |
| `SUPABASE_PROJECT_REF` | `swfyuwkptusceiouqlks` | Supabase Dashboard > Settings > API |
| `SUPABASE_URL` | `https://xxxxx.supabase.co` | Supabase Dashboard > Settings > API |
| `SUPABASE_ANON_KEY` | `eyJhbGc...` | Supabase Dashboard > Settings > API |
| `WEBFLOW_API_TOKEN` | `3a4b5c...` | Webflow Dashboard > Account > Integrations |
| `WEBFLOW_SITE_ID` | `65a0c...` | Webflow Dashboard > Site Settings |
| `WEBFLOW_SIGNALS_COLLECTION_ID` | `65b1d...` | Webflow Designer > Collections > Signals ID |
| `PPLX_API_KEY` | `pplx-xxxx...` | Perplexity Console (optional, for AI) |

---

## Architecture

```
┌────────────────────────┐
│ Local (Mac M1)  │
│  bootstrap.sh   │
│  (setup)        │
└────────────────┬────────┘
         │ Run once
         ↓
┌──────────────────────────────────────┐
│  GitHub Actions         │
│  one-click.yml          │
│  (deploy full stack)    │
└────────────────────────┬─────────────┘
               │ 1-click
               ↓
        ┌──────────────────┐
        │ Supabase DB  │
        └──────────────────┘
        ┌──────────────────┐
        │ Webflow Site │
        └──────────────────┘
        ┌──────────────────┐
        │ jsDelivr CDN │
        └──────────────────┘
               │
               ↓
    ┌──────────────────────────────────┐
    │ Webflow Designer     │
    │ Create Pages (ext)   │
    │ 1 button click       │
    └──────────────────────────────────┘
               │
               ↓
    ✅ LIVE & AUTOMATED!
```

---

## Next Steps

- [ ] Run `./scripts/bootstrap-mac-m1.sh`
- [ ] Download Designer extension from Releases
- [ ] Run GitHub Actions "One-Click" workflow
- [ ] Click "Create Klarpakke Pages" in Designer
- [ ] Test pages in browser
- [ ] Customize design in Webflow
- [ ] Go live! 🎉

---

## Support

Questions? Check:
- GitHub Issues: https://github.com/tombomann/klarpakke/issues
- Actions logs: https://github.com/tombomann/klarpakke/actions
- Supabase docs: https://supabase.com/docs
- Webflow docs: https://developers.webflow.com
