# GitHub Actions Setup Checklist

**Status:** ✅ Workflow deployed | ⏳ Secrets pending | 🚀 Ready to deploy

---

## 1️⃣ Add GitHub Secrets (5 min)

### Go to repo settings:
```
https://github.com/tombomann/klarpakke/settings/secrets/actions
```

### Add these secrets:

#### Required (CRITICAL)

- **`OCI_SSH_PRIVATE_KEY`**
  ```bash
  # On your local machine:
  cat ~/.ssh/oci_klarpakke
  # Copy entire output (including BEGIN/END lines)
  # Paste into GitHub secret
  ```

- **`PPLX_API_KEY`**
  ```
  Your Perplexity API key (pplx-...)
  ```

- **`STRIPE_SECRET_KEY`**
  ```
  Stripe test key: sk_test_...
  ```

#### Optional (for production)

- **`DATABASE_URL`**
  ```
  postgres://user:password@host:5432/klarpakke_db
  ```

- **`JWT_SECRET`**
  ```bash
  # Generate random secret:
  openssl rand -base64 32
  ```

- **`SLACK_WEBHOOK_URL`**
  ```
  https://hooks.slack.com/services/XXX/YYY/ZZZ
  ```

---

## 2️⃣ Setup OCI SSH Key (3 min)

### Local machine setup:

```bash
# Generate SSH key (if not exists)
ssh-keygen -t ed25519 -f ~/.ssh/oci_klarpakke -C "klarpakke-deploy"

# Add public key to OCI instance
ssh-copy-id -i ~/.ssh/oci_klarpakke.pub opc@129.151.201.41

# Test connection
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41 "echo OK"
```

### Add to GitHub:

```bash
# Copy private key
cat ~/.ssh/oci_klarpakke

# Add as GitHub secret:
# Name: OCI_SSH_PRIVATE_KEY
# Value: (paste entire private key)
```

---

## 3️⃣ Setup OCI Instance (10 min)

### SSH into instance:

```bash
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41
```

### Install Node.js & PM2:

```bash
# Update system
sudo dnf update -y

# Install Node.js 20
curl -fsSL https://rpm.nodesource.com/setup_20.x | sudo bash -
sudo dnf install -y nodejs

# Install PM2
sudo npm i -g pm2
sudo pm2 startup
pm2 save

# Install Git
sudo dnf install -y git

# Verify
node --version  # v20.x.x
npm --version   # 10.x.x
pm2 --version   # 5.x.x
```

### Create deployment directory:

```bash
mkdir -p ~/klarpakke-deploy
cd ~/klarpakke-deploy

# Create .env file (update with actual values)
cat > .env << EOF
NODE_ENV=staging
PORT=3001
PPLX_API_KEY=your_key
STRIPE_SECRET_KEY=your_key
EOF

# Test manual deployment
git clone https://github.com/tombomann/klarpakke.git .
cd backend
npm ci --production
npm start

# In another terminal, test
curl http://localhost:3001/health
```

---

## 4️⃣ Test GitHub Actions (2 min)

### Trigger deployment:

1. Go to: https://github.com/tombomann/klarpakke/actions
2. Find: "Deploy Backend to OCI"
3. Click "Run workflow"
4. Select: `staging`
5. Click "Run workflow"

### Monitor progress:

- ✅ Checkout
- ✅ Setup Node.js
- ✅ Setup SSH
- ✅ Install dependencies
- ✅ Run tests
- ✅ Deploy to OCI
- ✅ Health check

### Verify deployment:

```bash
# SSH into OCI
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41

# Check process
pm2 list
pm2 logs klarpakke-backend --lines 20

# Health check
curl http://localhost:3001/health
```

---

## 5️⃣ Automatic Deployments (1 min)

### From now on, just push to main:

```bash
git add backend/
git commit -m "feat: add new feature"
git push origin main

# GitHub Actions automatically:
# 1. Runs tests
# 2. Deploys to OCI
# 3. Sends Slack notification
```

### Or manual trigger:

```
https://github.com/tombomann/klarpakke/actions/workflows/deploy-backend.yml
Click "Run workflow" button
```

---

## ✅ Quick Verification

### After setup, verify everything works:

```bash
# 1. Check GitHub secrets exist
echo "✅ Secrets configured"

# 2. Check OCI instance is reachable
ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41 "pm2 list"

# 3. Trigger test deployment
# Go to Actions tab → Run workflow → staging

# 4. Check deployment succeeded
curl http://129.151.201.41:3001/health
```

---

## 🚨 Troubleshooting

### Deployment fails: "SSH key not found"
- [ ] Verify `OCI_SSH_PRIVATE_KEY` secret exists
- [ ] Check key format (should start with `-----BEGIN OPENSSH PRIVATE KEY-----`)
- [ ] Re-add secret if corrupted

### Deployment fails: "Permission denied (publickey)"
- [ ] Run: `ssh-copy-id -i ~/.ssh/oci_klarpakke.pub opc@129.151.201.41`
- [ ] Test: `ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41 "echo OK"`

### Backend not responding
- [ ] SSH into OCI: `ssh -i ~/.ssh/oci_klarpakke opc@129.151.201.41`
- [ ] Check: `pm2 list`
- [ ] View logs: `pm2 logs klarpakke-backend --lines 50`
- [ ] Restart: `pm2 restart klarpakke-backend`

### Port 3001 already in use
- [ ] Find process: `sudo lsof -i :3001`
- [ ] Kill it: `sudo kill -9 <PID>`
- [ ] Restart PM2: `pm2 start npm --name "klarpakke-backend" -- start`

---

## 📚 Related Docs

- Full deployment guide: [`docs/DEPLOY.md`](../DEPLOY.md)
- GitHub Actions workflow: [`.github/workflows/deploy-backend.yml`](./workflows/deploy-backend.yml)
- OCI Instance IP: `129.151.201.41`
- Backend port: `3001`

---

## 🎯 Next Steps

1. **Complete all steps above** (15 min total)
2. **Run test deployment** from GitHub Actions
3. **Verify backend is live** at http://129.151.201.41:3001/health
4. **Start pushing code** to main (automatic deployments)

**Status: READY TO DEPLOY** ✅
