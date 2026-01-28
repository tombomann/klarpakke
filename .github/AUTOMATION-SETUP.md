# 🚀 Klarpakke Full Automation Setup

**Status**: Production-ready CI/CD pipeline configured

**Date**: 2026-01-28  
**Version**: 1.0.0

---

## 🌟 Quick Start

### 1. Verify GitHub Secrets

Go to: **Settings → Secrets and variables → Actions**

Ensure these are set:

```
✅ SUPABASE_ACCESS_TOKEN        (Supabase service role key)
✅ SUPABASE_PROJECT_REF         (Project ID, e.g., "abc123xyz")
✅ SUPABASE_URL                 (Project URL, e.g., "https://abc123.supabase.co")
✅ SUPABASE_ANON_KEY            (Public anon key from project)
✅ PROD_SUPABASE_URL            (Production Supabase URL if different)
```

If any are missing:
1. Go to Supabase dashboard → Project settings
2. Copy values
3. Paste into GitHub Secrets

### 2. Set Up GitHub Environments (Optional but Recommended)

For manual approval before production:

**Settings → Environments → Create new environment**

**Environment 1: `staging`**
- Set deployment branch: `main`
- Required reviewers: (optional)

**Environment 2: `production`**
- Set deployment branch: `main`
- Required reviewers: Add yourself or team
- Deployment branches: Allow deployments only from main

---

## ⚡ How the Pipeline Works

### Trigger Events

The pipeline runs automatically on:

1. **Push to `main`** with changes in:
   - `web/**`
   - `supabase/**`
   - `scripts/deploy-*.sh`
   - `package.json`

2. **Manual trigger** via `workflow_dispatch`:
   - Go to: **Actions → Auto-Deploy Pipeline → Run workflow**
   - Select: `staging` or `production`

### Pipeline Stages

```
┌─────────────────────────────────────────────────────────────┐
│ STAGE 1: Lint & Build (runs always)                         │
├─────────────────────────────────────────────────────────────┤
│ ✓ Check JS syntax (klarpakke-site.js, calculator.js)       │
│ ✓ Minify web assets → web/dist/                            │
│ ✓ Upload artifacts for next stages                         │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ STAGE 2: Supabase Deploy (needs Stage 1)                    │
├─────────────────────────────────────────────────────────────┤
│ ✓ Verify Supabase secrets                                  │
│ ✓ Login with SUPABASE_ACCESS_TOKEN                         │
│ ✓ Run migrations (dry-run first)                           │
│ ✓ Deploy Edge Functions                                    │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ STAGE 3: Webflow Setup (needs Stage 1)                      │
├─────────────────────────────────────────────────────────────┤
│ ✓ Create runtime config (Supabase URL + anon key)          │
│ ✓ Generate webflow-loader.js                              │
│ ✓ Include Webflow setup instructions                       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ STAGE 4: Health Check (needs all above)                     │
├─────────────────────────────────────────────────────────────┤
│ ✓ Verify Supabase connectivity                             │
│ ✓ Check web script syntax                                  │
│ ✓ Generate deployment summary                              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ STAGE 5: Deploy to Staging (automatic)                      │
├─────────────────────────────────────────────────────────────┤
│ ✓ Update staging Webflow preview                           │
│ ✓ Sync bundles to staging CDN                              │
│ ✓ Email team for testing                                   │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ STAGE 6: Deploy to Production (MANUAL APPROVAL)             │
├─────────────────────────────────────────────────────────────┤
│ ⏳ Waits for GitHub Environment approval                    │
│ ✓ Once approved: Push to production                         │
│ ✓ Create release tag                                       │
│ ✓ Notify team                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 🌐 Webflow Integration

### Adding Klarpakke to Webflow

1. **After first pipeline run**, check:
   - Go to **Actions → Auto-Deploy Pipeline → Latest run**
   - Download artifact: `webflow-loader` → `loader.js`
   - Or find the Webflow snippet in the deployment summary

2. **In Webflow Editor**:
   - Go to **Site Settings → Custom Code → Footer**
   - Paste:
     ```html
     <script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@{COMMIT_SHA}/web/dist/webflow-loader.js"></script>
     ```
     Replace `{COMMIT_SHA}` with the commit hash from GitHub

3. **Publish Webflow site**
   - The loader will inject config + load scripts automatically
   - No manual JS needed in Webflow Custom Code

---

## 📊 Available npm Scripts

```bash
# Build web assets
npm run build:web

# Generate Webflow loader
npm run deploy:webflow

# Deploy backend (existing)
npm run deploy:backend

# Full CI chain
npm run ci:all

# Supabase commands
npm run supabase:start
npm run supabase:stop
npm run supabase:reset
```

---

## ⚠️ Key Environment Variables

| Variable | Source | Used For |
|----------|--------|----------|
| `SUPABASE_ACCESS_TOKEN` | GitHub Secrets | Supabase CLI login |
| `SUPABASE_PROJECT_REF` | GitHub Secrets | Project ID for CLI |
| `SUPABASE_URL` | GitHub Secrets | Injected into Webflow loader |
| `SUPABASE_ANON_KEY` | GitHub Secrets | Injected into Webflow loader |
| `GITHUB_SHA` | GitHub Actions (auto) | Version tag for bundles |
| `DEBUG` | GitHub Secrets (optional) | Enable debug mode in loader |

---

## 🔍 Monitoring & Troubleshooting

### View Pipeline Runs

1. Go to **Actions** tab
2. Click **Auto-Deploy Pipeline**
3. Click any run to see detailed logs

### Common Issues

**Issue**: Secrets not found
- **Fix**: Check GitHub Settings → Secrets → verify exact key names

**Issue**: Supabase deploy fails
- **Fix**: Verify `SUPABASE_ACCESS_TOKEN` has correct permissions
- **Check**: Go to Supabase → Settings → Access Tokens

**Issue**: Webflow loader doesn't load
- **Fix**: Check browser console for 404 on script URL
- **Verify**: Commit hash is correct in Webflow script tag

**Issue**: Production approval is stuck
- **Fix**: Go to **Environments → production → Active deployments → Approve/Reject**

---

## 🚀 Next Steps

1. ✅ **First Deploy**:
   - Push a small change to `main` (e.g., comment in web/klarpakke-site.js)
   - Watch the pipeline run
   - Check all stages pass

2. ✅ **Test Staging**:
   - Download webflow-loader artifact
   - Add to staging Webflow site
   - Test all flows: pricing → dashboard → settings → calculator

3. ✅ **Approve Production**:
   - Once staging looks good
   - Go to **Environments → production → Active deployments**
   - Click **Review deployments → Approve**

4. ✅ **Monitor Production**:
   - Check production Webflow site
   - Verify signals load in dashboard
   - Monitor for errors

---

## 📄 Reference Files

- **Workflow**: `.github/workflows/auto-deploy.yml`
- **Build Script**: `scripts/build-web.js`
- **Loader Generator**: `scripts/gen-webflow-loader.js`
- **Updated package.json**: `package.json`

---

**Questions?** Check `.github/GITHUB_SETUP.md` or create an issue.
