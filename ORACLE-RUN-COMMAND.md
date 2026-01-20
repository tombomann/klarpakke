# 🚀 Oracle Run Command - Deploy Without Serial Console

**Status**: ✅ Fastest method available  
**Time**: 20-25 minutes  
**Advantage**: No browser console needed, direct command execution  

---

## Why Run Command is Better

✅ **No Serial Console UI needed** - Direct command execution  
✅ **Faster** - Executes immediately  
✅ **Better for automation** - CLI-based  
✅ **Already enabled** - Compute Instance Run Command is Running  

---

## Method 1: Using OCI CLI (Recommended)

### Prerequisites
```bash
# Install OCI CLI if not already installed
# macOS
brew install oci-cli

# Or download from: https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm

# Verify installation
oci --version
```

### Setup OCI CLI (One-Time)
```bash
# Configure OCI CLI with your credentials
oci setup config

# Answer the prompts:
# - Location of config file: /Users/taj/.oci/config
# - User OCID: (from Oracle Cloud Console → User Settings)
# - Tenancy OCID: (from Oracle Cloud Console → Tenancy Details)
# - Region: eu-stockholm-1
# - Generate new API key: Y
```

### Deploy Using Run Command

**Step 1: Get Instance OCID**
```bash
# From your browser, look at the instance details page
# Or run this to find it:
oci compute instance list --compartment-id <your-compartment-ocid> \
  --query "data[?display-name=='klarpakke-vm'].id" --raw-output

# Result should look like:
# ocid1.instance.oc1.eu-stockholm-1.anqxeljr25mhs5acnd52d4o3ari6urgi54xzwldcbg2rvkgph6pngw5mjvsa

# Save this as INSTANCE_ID
INSTANCE_ID="ocid1.instance.oc1.eu-stockholm-1.anqxeljr25mhs5acnd52d4o3ari6urgi54xzwldcbg2rvkgph6pngw5mjvsa"
```

**Step 2: Run Deploy Command**
```bash
# Execute the deployment script
oci compute instance-action run-command \
  --instance-id $INSTANCE_ID \
  --command "curl -fsSL https://raw.githubusercontent.com/tombomann/klarpakke/main/scripts/oracle-deploy.sh | bash" \
  --wait-for-state SUCCEEDED

# This will:
# 1. Queue the command on the instance
# 2. Execute it immediately
# 3. Wait for completion (20-25 minutes)
# 4. Show you the results
```

**Step 3: Monitor Progress**
```bash
# While deployment is running, you can check status:
oci compute instance get --instance-id $INSTANCE_ID \
  --query "data.{id:id,state:lifecycle_state,display_name:display_name}"

# Or check the deployment logs via SSH (in another terminal):
ssh -i ~/.ssh/oci_klarpakke opc@79.76.63.189 'pm2 logs klarpakke'
```

---

## Method 2: Using Makefile (After SSH Key Setup)

```bash
# One-liner deployment
make oci-deploy

# This will:
# 1. Check SSH connection
# 2. Pull latest code
# 3. Install dependencies
# 4. Restart PM2
# 5. Verify deployment
```

---

## Method 3: Direct SSH (If You Have Key)

```bash
# SSH into instance
ssh -i ~/.ssh/oci_klarpakke opc@79.76.63.189

# Then paste deploy script:
bash -s << 'EOF'
curl -fsSL https://raw.githubusercontent.com/tombomann/klarpakke/main/scripts/oracle-deploy.sh | bash
EOF
```

---

## Verification After Deploy

### Quick Health Check
```bash
# From your Mac, test the endpoint
curl http://79.76.63.189:3000/health

# Expected response:
# {"status":"ok","timestamp":"2026-01-20T09:30:00.000Z","service":"klarpakke-backend"}
```

### Full Validation
```bash
make oci-test

# This runs 6 comprehensive tests:
# 1. SSH Connection
# 2. PM2 Process Status
# 3. Internal Health Endpoint
# 4. External Health Endpoint
# 5. Database Connection
# 6. System Resources
```

---

## Recommended: OCI CLI Method (Fastest)

**Why?** 
- Direct command execution
- No browser interaction needed
- Full automation-ready
- Can be scripted in CI/CD

**Quick Setup:**
```bash
# 1. Install OCI CLI
brew install oci-cli

# 2. Configure (one-time)
oci setup config

# 3. Get instance OCID from Oracle Console
# 4. Run command:
oci compute instance-action run-command \
  --instance-id ocid1.instance.oc1.eu-stockholm-1.anqxeljr25mhs5acnd52d4o3ari6urgi54xzwldcbg2rvkgph6pngw5mjvsa \
  --command "curl -fsSL https://raw.githubusercontent.com/tombomann/klarpakke/main/scripts/oracle-deploy.sh | bash" \
  --wait-for-state SUCCEEDED

# 5. Wait 20-25 minutes
# 6. Test: curl http://79.76.63.189:3000/health
```

---

## Timeline

```
09:18 - Start OCI CLI command
09:20 - Deploy script begins
09:45 - Deploy completes
09:50 - Health check passes
10:00 - Backend LIVE ✅
```

---

## Troubleshooting

**Q: "Run Command not available" error?**  
A: You have it enabled but may need to configure IAM policies. Use SSH method instead.

**Q: OCI CLI not installed?**  
A: `brew install oci-cli` or download from Oracle docs

**Q: Don't have API key configured?**  
A: Run `oci setup config` to generate one

**Q: Deployment failed?**  
A: Script is idempotent - run it again! Or check: `make oci-logs`

---

## Next Steps

1. ✅ Install OCI CLI or use make/SSH method
2. ✅ Run deployment command
3. ✅ Wait 20-25 minutes
4. ✅ Verify with health check
5. ✅ Check GitHub Actions for CI/CD setup
6. ✅ Next deploys: Just `git push` to main!

---

**Recommended Action**: Use the **OCI CLI method** or **make oci-deploy** for fastest execution!
