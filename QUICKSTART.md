# 🚀 Klarpakke Trading Analysis - Quick Start

## ONE-COMMAND SETUP ⚡

```bash
cd ~/klarpakke && git pull && chmod +x scripts/ultimate-fix.sh && bash scripts/ultimate-fix.sh
```

Dette scriptet gjør **ALT** automatisk:
1. ✅ Åpner Supabase dashboard
2. ✅ Ber deg lime inn 2 keys (eneste manuelle steg)
3. ✅ Validerer keys
4. ✅ Tester lokalt
5. ✅ Synkroniserer til GitHub
6. ✅ Trigger workflow
7. ✅ Åpner monitoring

---

## 📋 Hva du trenger

- macOS (for `open` kommando)
- Homebrew
- Git
- Python 3
- Tilgang til Supabase dashboard
- GitHub CLI (installeres automatisk hvis mangler)

---

## 🎯 Steg-for-steg (hvis ultimate-fix.sh feiler)

### 1. Setup lokalt miljø

```bash
cd ~/klarpakke
git pull origin main
```

### 2. Hent API keys manuelt

```bash
# Åpne dashboard
open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/settings/api

# I browseren:
# - Kopier "anon public" key
# - Klikk "Reveal" ved "service_role" og kopier
```

### 3. Oppdater .env.migration

```bash
cat > .env.migration << 'EOF'
SUPABASE_PROJECT_ID=swfyuwkptusceiouqlks
SUPABASE_ANON_KEY=<paste_anon_key>
SUPABASE_SERVICE_ROLE_KEY=<paste_service_role_key>
SUPABASE_DB_URL="postgresql://postgres.swfyuwkptusceiouqlks:password@aws-1-eu-west-1.pooler.supabase.com:5432/postgres"
MAKE_TEAM_ID=219598
MAKE_API_TOKEN=your_make_token_here
EOF
```

### 4. Test lokalt

```bash
bash scripts/debug-keys.sh
```

### 5. Sync til GitHub

```bash
bash scripts/sync-secrets.sh push
```

### 6. Trigger workflow

```bash
gh workflow run trading-analysis.yml
gh run watch
```

---

## 🔧 Available Scripts

| Script | Beskrivelse |
|--------|-------------|
| `ultimate-fix.sh` | **ANBEFALT** - Full automated setup |
| `complete-setup.sh` | End-to-end med Supabase CLI (kan gi ugyldige keys) |
| `auto-fix-keys.sh` | Hent keys via Supabase CLI |
| `sync-secrets.sh` | Sync .env ↔️ GitHub Secrets |
| `debug-keys.sh` | Test og debug API keys |
| `test-analysis-local.sh` | Test Python script lokalt |

---

## 📊 Monitoring

### GitHub Actions
```bash
# Watch live
gh run watch

# List recent runs
gh run list --workflow="trading-analysis.yml" -L 10

# View logs
gh run view --log

# Or in browser
open https://github.com/tombomann/klarpakke/actions
```

### Supabase
```bash
# Open editor
open https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor

# Check aisignal table for:
# - status: pending → approved/rejected
# - approved_by/rejected_by: github_actions
# - approved_at/rejected_at: timestamps
```

---

## 🔄 Workflow Schedule

- **Automatisk:** Kjører hvert 15. minutt (`*/15 * * * *`)
- **Manuell trigger:** Via GitHub Actions UI eller `gh workflow run`

---

## ⚙️ Configuration

### Approval Thresholds

Rediger `scripts/analyze_signals.py`:

```python
# Current thresholds:
if rr_ratio >= 2.0 and confidence >= 0.75:
    decision = "approved"

# Adjust as needed:
# - rr_ratio: Risk/Reward ratio minimum
# - confidence: Confidence percentage minimum (0.0-1.0)
```

### Workflow Frequency

Rediger `.github/workflows/trading-analysis.yml`:

```yaml
schedule:
  - cron: '*/15 * * * *'  # Change to desired frequency
```

---

## 🚨 Troubleshooting

### Keys ikke gyldige

```bash
# Debug lokalt
bash scripts/debug-keys.sh

# Hvis feiler, kjør ultimate-fix på nytt
bash scripts/ultimate-fix.sh
```

### Workflow feiler i GitHub Actions

```bash
# Check secrets er satt
gh secret list

# Re-sync
bash scripts/sync-secrets.sh push

# Trigger på nytt
gh workflow run trading-analysis.yml
```

### Python script feiler

```bash
# Test lokalt med full output
source .env.migration
export SUPABASE_PROJECT_ID
export SUPABASE_SERVICE_ROLE_KEY
python3 scripts/analyze_signals.py
```

---

## 📞 Support

Problemer? Kjør debug og sjekk output:

```bash
bash scripts/debug-keys.sh
gh run view --log
```

---

## 🎉 Success Indicators

✅ Lokalt script kjører uten errors  
✅ GitHub Actions workflow blir grønn  
✅ Supabase `aisignal` tabell oppdateres  
✅ `approved_by` eller `rejected_by` kolonner fylles ut  

---

**Ready to go? Run this:**

```bash
cd ~/klarpakke && git pull && bash scripts/ultimate-fix.sh
```
