# 🚀 Klarpakke Quick Start

**Mål:** Få full CI/CD pipeline kjørende på 5 minutter.

---

## Forutsetninger

```bash
# 1. Node.js (v18+)
node --version

# 2. Supabase CLI
supabase --version
# Installer om mangler: npm install -g supabase

# 3. GitHub CLI
gh --version
# Installer om mangler: brew install gh
```

---

## ⚡ 3-Stegs Setup

### Steg 1: Klon og installer

```bash
# Klon repo
git clone https://github.com/tombomann/klarpakke.git
cd klarpakke

# Installer dependencies
npm install
```

### Steg 2: Konfigurer Supabase (Interaktivt)

```bash
# Kjør interaktivt setup-script
bash scripts/setup-supabase-env.sh
```

**Dette scriptet vil:**
1. Logge deg inn på Supabase (via browser)
2. Liste alle prosjektene dine
3. La deg velge riktig prosjekt
4. Automatisk hente alle API-nøkler
5. Verifisere at alt er korrekt format
6. Opprette `.env` med alle nødvendige verdier

**Output:** `.env` fil med:
- `SUPABASE_PROJECT_REF` (20-tegns ID)
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_ACCESS_TOKEN`

---

### Steg 3: Sync til GitHub Secrets

```bash
# Autentiser GitHub CLI (om ikke allereie gjort)
gh auth login

# Sync alle verdier til GitHub Secrets
bash scripts/sync-github-secrets.sh
```

**Dette scriptet vil:**
- Lese `.env`
- Validere alle verdier
- Sette GitHub Secrets automatisk
- Verifisere at synkronisering fungerte

---

## ✅ Verifiser Setup

### Test 1: Lokal Build

```bash
# Test full build chain
npm run ci:all

# Forventa output:
# ✓ build:web (minify JS)
# ✓ deploy:webflow (generate loader)
# ✓ deploy:backend (migrations + functions)
```

### Test 2: Trigger CI/CD Pipeline

```bash
# Trigger staging deploy
gh workflow run '🚀 Auto-Deploy Pipeline' --ref main -f environment=staging

# Se status live
gh run watch

# ELLER list runs
gh run list --workflow auto-deploy.yml --limit 3
```

### Test 3: Verifiser GitHub Secrets

```bash
# List alle secrets
gh secret list

# Forventa output:
SUPABASE_ACCESS_TOKEN       Updated 2026-01-28
SUPABASE_ANON_KEY          Updated 2026-01-28
SUPABASE_PROJECT_REF       Updated 2026-01-28
SUPABASE_SERVICE_ROLE_KEY  Updated 2026-01-28
SUPABASE_URL               Updated 2026-01-28
```

---

## 🌐 Webflow Setup (Etter First Deploy)

1. **Last ned loader fra pipeline**:
   - Gå til: **Actions → Auto-Deploy Pipeline → Latest run**
   - Last ned artifact: `webflow-loader`

2. **Legg til i Webflow**:
   - Gå til: **Webflow Project Settings → Custom Code → Footer**
   - Lim inn:
     ```html
     <script src="https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/dist/webflow-loader.js"></script>
     ```

3. **Publiser Webflow site**

4. **Test**:
   - Åpne siden i nettleser
   - Åpne DevTools Console (Cmd+Option+J)
   - Sjekk for `[Klarpakke]` logger

---

## 🔧 Troubleshooting

### Problem: "Invalid project ref format"

```bash
# Sjekk lengde (må være eksakt 20)
echo ${#SUPABASE_PROJECT_REF}

# Sjekk format (kun små bokstaver)
echo $SUPABASE_PROJECT_REF | grep -E '^[a-z]{20}$'

# Kjør setup igjen om feil:
bash scripts/setup-supabase-env.sh
```

### Problem: "Invalid access token format"

```bash
# Sjekk at token starter med sbp_
echo ${SUPABASE_ACCESS_TOKEN:0:10}
# Skal vise: sbp_...

# Om feil, hent ny token:
# https://supabase.com/dashboard/account/tokens
```

### Problem: Deploy-script feiler

```bash
# Test Supabase connectivity manuelt
curl -H "apikey: $SUPABASE_ANON_KEY" \
     "$SUPABASE_URL/rest/v1/"

# Skal returnere JSON (ikke 404)

# Test Supabase CLI link
supabase link --project-ref $SUPABASE_PROJECT_REF
```

### Problem: GitHub Actions feiler

```bash
# Hent logger for siste feilede kjøring
gh run view $(gh run list --workflow auto-deploy.yml --json databaseId -q '.[0].databaseId') --log-failed

# Sjekk at secrets er satt riktig
gh secret list
```

---

## 📚 Neste Steg

- **Full dokumentasjon**: [README.md](README.md)
- **CI/CD guide**: [.github/AUTOMATION-SETUP.md](.github/AUTOMATION-SETUP.md)
- **Production plan**: [docs/PRODUCTION-PLAN.md](docs/PRODUCTION-PLAN.md)
- **Webflow manual**: [docs/WEBFLOW-MANUAL.md](docs/WEBFLOW-MANUAL.md)

---

## 🆘 Kommandooversikt

```bash
# Setup (kjør en gang)
bash scripts/setup-supabase-env.sh     # Hent Supabase credentials
bash scripts/sync-github-secrets.sh    # Sync til GitHub

# Development
npm run build:web                      # Minify JS
npm run deploy:webflow                 # Generate loader
npm run deploy:backend                 # Deploy Supabase
npm run ci:all                         # Full chain

# CI/CD
gh workflow run '🚀 Auto-Deploy Pipeline' --ref main -f environment=staging
gh run watch                           # Se status
gh run list --workflow auto-deploy.yml # List runs

# Debugging
gh secret list                         # List GitHub Secrets
supabase projects list                 # List Supabase projects
supabase functions list                # List deployed functions
```

---

**Spørsmål?** Opprett issue eller sjekk [full dokumentasjon](README.md).
