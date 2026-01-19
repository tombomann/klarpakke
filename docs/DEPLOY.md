# Klarpakke Backend Deployment Guide

## Overview

This guide explains how to deploy Klarpakke backend to Oracle OCI Compute Instance using GitHub Actions.

**Deployment Flow:**
```
git push main
    ↓
GitHub Actions triggered
    ↓
Backend built & tested on ubuntu-latest
    ↓
SSH tunnel to OCI instance (129.151.201.41)
    ↓
Deploy via PM2 (process manager)
    ↓
Health check (curl /health)
    ↓
✅ Live on port 3001
```

---

## Prerequisites

### 1. OCI Compute Instance
- **OS:** Oracle Linux 9 (or compatible)
- **IP:** 129.151.201.41
- **User:** opc
- **Region:** Stockholm (eu-stockholm-1)
- **Installed:**
  - Node.js 20
  - npm
  - PM2 (`npm i -g pm2`)
  - Git
  - curl

### 2. SSH Key Setup

**On your local machine:**
```bash
# If you don't have an SSH key, generate one
ssh-keygen -t ed25519 -f ~/.ssh/oci_klarpakke -C "klarpakke-deploy"

# Copy public key to OCI
ssh-copy-id -i ~/.ssh/oci_klarpakke.pub opc@129.151.201.41

# Test connection
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41
```

**Add to GitHub Secrets:**
```bash
# Copy private key
cat ~/.ssh/oci_klarpakke | pbcopy  # macOS
# or
cat ~/.ssh/oci_klarpakke | xclip -selection clipboard  # Linux

# Add to GitHub:
# 1. Go to: https://github.com/tombomann/klarpakke/settings/secrets/actions
# 2. New secret: OCI_SSH_PRIVATE_KEY
# 3. Paste key
```

---

## GitHub Secrets Setup

**Required Secrets** (add to repo settings):

| Secret | Example | Notes |
|--------|---------|-------|
| `OCI_SSH_PRIVATE_KEY` | `-----BEGIN OPENSSH PRIVATE KEY-----` | SSH private key for OCI instance |
| `PPLX_API_KEY` | `pplx-xxxxxxxxxxxxx` | Perplexity API key |
| `STRIPE_SECRET_KEY` | `sk_test_xxxxxxxxxxxxx` | Stripe test/live key |
| `DATABASE_URL` | `postgres://user:pass@host/db` | PostgreSQL connection string (if applicable) |
| `JWT_SECRET` | `random-secret-string` | JWT signing secret |
| `SLACK_WEBHOOK_URL` | `https://hooks.slack.com/...` | Optional: Slack notifications |

**How to add secrets:**
1. Go to: https://github.com/tombomann/klarpakke/settings/secrets/actions
2. Click "New repository secret"
3. Name: (from table above)
4. Value: (paste secret)
5. Click "Add secret"

---

## Deployment Methods

### Method 1: Automatic (Push to Main)

**Any commit to `main` that touches `backend/` will trigger deployment:**

```bash
git add backend/
git commit -m "feat: add new endpoint"
git push origin main

# Watch deployment:
# https://github.com/tombomann/klarpakke/actions
```

### Method 2: Manual (Workflow Dispatch)

**Trigger deployment from GitHub UI:**

1. Go to: https://github.com/tombomann/klarpakke/actions
2. Find: "Deploy Backend to OCI"
3. Click "Run workflow"
4. Select environment (staging/production)
5. Click "Run workflow"

---

## Local OCI Setup (One-time)

### 1. SSH into OCI instance
```bash
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41
```

### 2. Install prerequisites
```bash
# Update system
sudo dnf update -y

# Install Node.js 20
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

# Install PM2 globally
sudo npm i -g pm2

# Setup PM2 startup
sudo pm2 startup
pm2 save

# Install Git
sudo dnf install -y git

# Verify installations
node --version  # v20.x.x
npm --version   # 10.x.x
pm2 --version   # 5.x.x
```

### 3. Create deployment directory
```bash
mkdir -p ~/klarpakke-deploy
cd ~/klarpakke-deploy
```

### 4. Test deployment manually
```bash
# Clone repo
git clone https://github.com/tombomann/klarpakke.git .

# Create .env
cat > .env << EOF
NODE_ENV=staging
PORT=3001
PPLX_API_KEY=your_key_here
STRIPE_SECRET_KEY=your_key_here
EOF

# Install & start
cd backend
npm ci --production
npm start

# In another terminal, test
curl http://localhost:3001/health
```

---

## Monitoring Deployment

### Check GitHub Actions
```
https://github.com/tombomann/klarpakke/actions
```

### SSH into OCI and check process
```bash
ssh opc@129.151.201.41

# Check PM2 status
pm2 list
pm2 logs klarpakke-backend  # View logs
pm2 status klarpakke-backend

# Check if port 3001 is listening
ss -tlnp | grep 3001

# Health check
curl http://localhost:3001/health
```

### View PM2 logs
```bash
ssh opc@129.151.201.41
pm2 logs klarpakke-backend --lines 100
pm2 logs klarpakke-backend --tail  # Real-time
```

---

## Troubleshooting

### Deployment fails: "SSH key not found"
**Solution:** Verify `OCI_SSH_PRIVATE_KEY` secret is set correctly
```bash
# On local machine
cat ~/.ssh/oci_klarpakke | head -1
# Should output: -----BEGIN OPENSSH PRIVATE KEY-----

# Check GitHub secret is identical
```

### Deployment fails: "Permission denied (publickey)"
**Solution:** SSH key not added to OCI instance
```bash
# On local machine
ssh-copy-id -i ~/.ssh/oci_klarpakke.pub opc@129.151.201.41
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41 "echo OK"
```

### Backend not responding on port 3001
**Solution:** Check PM2 process
```bash
ssh opc@129.151.201.41
pm2 list
pm2 logs klarpakke-backend --lines 50

# If dead, restart manually
pm2 start npm --name "klarpakke-backend" -- start
pm2 save
```

### Health check fails after deploy
**Solution:** Backend may need more time to start, or has errors
```bash
ssh opc@129.151.201.41
cd ~/klarpakke-deploy/backend
npm start  # Run manually to see errors
```

### Port 3001 already in use
**Solution:** Kill old process
```bash
ssh opc@129.151.201.41
sudo lsof -i :3001  # Find PID
sudo kill -9 <PID>  # Kill it
pm2 start npm --name "klarpakke-backend" -- start
```

---

## Rollback

If deployment fails, rollback to previous version:

```bash
ssh opc@129.151.201.41
cd ~/klarpakke-deploy

# Revert git
git reset --hard <previous-commit-sha>

# Restart
pm2 delete klarpakke-backend
pm2 start npm --name "klarpakke-backend" -- start
ps aux | grep node
```

---

## Production Deployment

### Considerations

1. **Before deploying to production:**
   - Test in staging first
   - Run full test suite locally
   - Verify all secrets are production keys

2. **Staging vs Production:**
   ```bash
   # Staging: Lower cost, can restart anytime
   # Production: Mission-critical, use proper database backups
   
   # Use workflow input to choose:
   # https://github.com/tombomann/klarpakke/actions/workflows/deploy-backend.yml
   ```

3. **Database backups:**
   ```bash
   # Before major deployments
   ssh opc@129.151.201.41
   pg_dump klarpakke_db > backup_$(date +%Y%m%d).sql
   ```

---

## Useful Commands

```bash
# SSH into OCI
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41

# View backend logs (real-time)
pm2 logs klarpakke-backend --tail

# Restart backend
pm2 restart klarpakke-backend

# Stop backend
pm2 stop klarpakke-backend

# Health check from local
curl http://129.151.201.41:3001/health

# Check disk usage on OCI
df -h

# Check memory on OCI
free -h

# Check system load
uptime
```

---

## GitHub Workflow Status

**Live Deployments:**
https://github.com/tombomann/klarpakke/actions/workflows/deploy-backend.yml

**Commit History:**
https://github.com/tombomann/klarpakke/commits/main

---

## Next Steps

1. ✅ Add SSH key to GitHub Secrets
2. ✅ Setup OCI instance with Node.js + PM2
3. ✅ Create `.env` file on OCI
4. ✅ Test manual deployment
5. ✅ Push to main and watch GitHub Actions
6. ✅ Verify backend is live at http://129.151.201.41:3001/health

---

**Questions?** Check logs:
- GitHub Actions: https://github.com/tombomann/klarpakke/actions
- OCI PM2: `ssh opc@129.151.201.41 'pm2 logs klarpakke-backend'`
