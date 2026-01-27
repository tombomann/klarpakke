# 🎨 Webflow Deployment Guide

**Visual step-by-step guide for deploying Klarpakke UI to Webflow**

---

## 📋 Prerequisites

- [ ] Webflow account with site created
- [ ] Site has `/app/dashboard` page
- [ ] `web/klarpakke-ui.js` ready (2.5 KB JavaScript file)
- [ ] Webflow API token generated
- [ ] Collection created for signals (CMS)

---

## 🚀 Quick Deploy (2 minutes)

### Step 1: Paste JavaScript (45 seconds)

**What to do:**
1. Open Webflow Designer: https://webflow.com/dashboard/sites/klarpakke/designer
2. Click **⚙️ (Project Settings)** - top left corner
3. Click **'Custom Code'** tab
4. Scroll down to **'Before </body> tag'** section
5. Click inside the code box
6. **Paste (Cmd+V)** - JavaScript is already in clipboard!
7. Click **'Save Changes'** button

**Visual reference:**
```
┌─────────────────────────────────────────────┐
│ Webflow Designer                          [⚙️]  │
├─────────────────────────────────────────────┤
│ Project Settings                              │
│ ┌─────────────────────────────────────────┐ │
│ │ [General] [Custom Code] [SEO] ...         │ │
│ ├─────────────────────────────────────────┤ │
│ │ Head Code:                                │ │
│ │ ┌────────────────────────────────────┐ │ │
│ │ │ <!-- Analytics, Meta tags -->        │ │ │
│ │ └────────────────────────────────────┘ │ │
│ │                                           │ │
│ │ Before </body> tag:  ← PASTE HERE       │ │
│ │ ┌────────────────────────────────────┐ │ │
│ │ │ <script>                            │ │ │
│ │ │ // Klarpakke UI logic here          │ │ │
│ │ │ </script>                           │ │ │
│ │ └────────────────────────────────────┘ │ │
│ │                                           │ │
│ │              [Save Changes] ← CLICK    │ │
│ └─────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**What gets pasted:**
```javascript
// Klarpakke UI Script (2.5 KB)
// Handles approve/reject button clicks
// Calls Supabase Edge Functions
// Updates UI in real-time
```

---

### Step 2: Password Protection (30 seconds)

**What to do:**
1. In Webflow Designer, click **'Pages'** panel (left sidebar)
2. Find `/app/dashboard` page in the list
3. Click **⚙️ (Page Settings)** icon next to the page
4. Toggle **'Password Protection'** → **ON**
5. Enter password: `tom`
6. Click **'Save'**

**Visual reference:**
```
┌─────────────────────────────────┐
│ Pages Panel                      │
├─────────────────────────────────┤
│ 🏠 Home                        │
│ 📋 /app/dashboard [⚙️] ← CLICK │
│ 📈 /app/positions            │
│ ⚡ /app/signals               │
└─────────────────────────────────┘

┌─────────────────────────────────┐
│ Page Settings (/app/dashboard) │
├─────────────────────────────────┤
│ Page Name: Dashboard           │
│ Slug: /app/dashboard           │
│                                │
│ Password Protection:           │
│   [✓] Enable  ← TOGGLE ON      │
│                                │
│   Password: [•••] ← tom       │
│                                │
│              [Save] ← CLICK     │
└─────────────────────────────────┘
```

**Why password protection:**
- Demo mode - not public yet
- Easy access control (no auth setup needed)
- Can change password before production

---

### Step 3: Publish (30 seconds)

**What to do:**
1. Click **'Publish'** button (top right, purple button)
2. Select domain: `klarpakke-c65071.webflow.io`
3. Click **'Publish to Selected Domains'**
4. Wait for progress bar (10-15 seconds)
5. See **'Successfully published!'** message
6. Click **'View Site'** to test

**Visual reference:**
```
┌─────────────────────────────────────────────┐
│ Designer Toolbar        [📤 Publish] ← CLICK │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Publish to Webflow                          │
├─────────────────────────────────────────────┤
│ Select domains:                             │
│   [✓] klarpakke-c65071.webflow.io ← SELECT │
│   [ ] klarpakke.no (custom domain)          │
│                                             │
│   [Publish to Selected Domains] ← CLICK   │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Publishing...                               │
│ ██████████████████▒▒▒▒▒▒▒▒▒ 75%        │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ ✅ Successfully published!                 │
│                                             │
│ Your site is live at:                       │
│ https://klarpakke-c65071.webflow.io         │
│                                             │
│              [View Site] ← CLICK           │
└─────────────────────────────────────────────┘
```

---

## 🧪 Testing After Publish

### 1. Password Test
```bash
# Terminal test
curl -I https://klarpakke-c65071.webflow.io/app/dashboard

# Expected: HTTP/1.1 401 Unauthorized
```

### 2. Browser Test
1. Open: https://klarpakke-c65071.webflow.io/app/dashboard
2. Enter password: `tom`
3. Open Console (F12 or Cmd+Option+J)
4. Look for: `[Klarpakke] UI script loaded`
5. Click **'Approve'** button on any signal card
6. Verify: `[Klarpakke] Success: {signal_id: "...", status: "approved"}`

### 3. Auto-Sync Test
```bash
# Generate demo signals
make paper-seed

# Wait 5 minutes (GitHub Actions runs every 5 min)
# Check: https://github.com/tombomann/klarpakke/actions/workflows/webflow-sync.yml

# Signals should appear in Webflow dashboard automatically
```

---

## 🔧 Troubleshooting

### JavaScript not loading
**Symptom:** Console shows no `[Klarpakke]` messages

**Fix:**
1. Verify Custom Code saved: Project Settings → Custom Code
2. Hard refresh: Cmd+Shift+R (clears cache)
3. Check browser console for errors
4. Re-paste JavaScript and publish again

### Approve button not working
**Symptom:** Click does nothing, no console logs

**Fix:**
1. Check CORS: Supabase Dashboard → Settings → API → Add `*.webflow.io`
2. Verify Edge Function deployed: `make edge-logs`
3. Test Edge Function manually:
   ```bash
   curl -X POST https://swfyuwkptusceiouqlks.supabase.co/functions/v1/approve-signal \
     -H "Authorization: Bearer $SUPABASE_ANON_KEY" \
     -d '{"signal_id": "test", "action": "APPROVE"}'
   ```

### Password not working
**Symptom:** Password prompt doesn't appear

**Fix:**
1. Verify password protection enabled: Pages → /app/dashboard → Settings
2. Re-publish site: Publish button → Publish to Selected Domains
3. Clear browser cache: Cmd+Shift+Delete
4. Test in incognito window

---

## 📊 Webflow Collection ID

**How to find your Collection ID:**

### Method 1: Webflow Designer
1. Open Webflow Designer
2. Click **CMS** panel (left sidebar)
3. Click on **'Signals'** collection
4. Check URL: `https://webflow.com/design/klarpakke?collectionId=COLLECTION_ID`
5. Copy the `collectionId` parameter

### Method 2: Webflow API
```bash
# List all collections
curl https://api.webflow.com/v2/sites/SITE_ID/collections \
  -H "Authorization: Bearer $WEBFLOW_API_TOKEN"

# Find collection named "Signals" in response
# Copy the "id" field
```

### Method 3: Auto-script
```bash
# Run helper script
bash scripts/get-webflow-collection-id.sh

# Follow prompts to paste Site ID
# Script will list all collections with IDs
```

---

## 📚 Resources

- **Webflow Help**: https://help.webflow.com/hc/en-us/articles/40846212086035-Webflow-Cloud-overview
- **Webflow API Docs**: https://developers.webflow.com/reference/introduction
- **Klarpakke GitHub**: https://github.com/tombomann/klarpakke
- **Supabase Dashboard**: https://supabase.com/dashboard/project/swfyuwkptusceiouqlks

---

**Last updated:** 27. januar 2026  
**Version:** 1.0
