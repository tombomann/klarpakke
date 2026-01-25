#!/usr/bin/env bash
set -euo pipefail

# Oracle Cloud VM Recovery Script
# Diagnoses and recovers VM connectivity issues

VM_IP="${ORACLE_VM_IP:-129.151.201.41}"
SSH_KEY="${HOME}/.ssh/oracle_new"
REGION="eu-stockholm-1"

echo "🔍 ORACLE VM RECOVERY"
echo "==================="
echo ""

# Step 1: Network diagnostics
echo "[1/5] Network Diagnostics"
if ping -c 2 -W 3 "$VM_IP" >/dev/null 2>&1; then
    echo "  ✅ VM is reachable (ping OK)"
    VM_REACHABLE=true
else
    echo "  ❌ VM is unreachable (ping timeout)"
    VM_REACHABLE=false
fi

# Step 2: SSH test
echo ""
echo "[2/5] SSH Connectivity"
if [ "$VM_REACHABLE" = true ]; then
    if ssh -i "$SSH_KEY" -o ConnectTimeout=5 -o StrictHostKeyChecking=no "opc@$VM_IP" "echo 'SSH OK'" >/dev/null 2>&1; then
        echo "  ✅ SSH connection successful"
        echo ""
        echo "🎉 VM is healthy! No recovery needed."
        exit 0
    else
        echo "  ❌ SSH connection failed (auth/firewall issue)"
    fi
else
    echo "  ⏭️  Skipped (VM unreachable)"
fi

# Step 3: Check if OCI CLI is configured
echo ""
echo "[3/5] OCI CLI Configuration"
if command -v oci >/dev/null 2>&1; then
    if oci iam region list >/dev/null 2>&1; then
        echo "  ✅ OCI CLI configured"
        OCI_CONFIGURED=true
    else
        echo "  ⚠️  OCI CLI installed but not configured"
        OCI_CONFIGURED=false
    fi
else
    echo "  ❌ OCI CLI not installed"
    OCI_CONFIGURED=false
fi

# Step 4: Automatic VM recovery via OCI CLI
if [ "$OCI_CONFIGURED" = true ]; then
    echo ""
    echo "[4/5] Automated VM Recovery"
    
    # List instances
    echo "  🔍 Searching for instances..."
    INSTANCES=$(oci compute instance list --compartment-id "$(oci iam compartment list --query 'data[0].id' --raw-output)" \
        --region "$REGION" --query 'data[?"primary-public-ip"==`'"$VM_IP"'`]' 2>/dev/null || echo "[]")
    
    if [ "$INSTANCES" != "[]" ]; then
        INSTANCE_ID=$(echo "$INSTANCES" | jq -r '.[0].id')
        INSTANCE_STATE=$(echo "$INSTANCES" | jq -r '.[0]."lifecycle-state"')
        
        echo "  📋 Found instance: $INSTANCE_ID"
        echo "  📊 Current state: $INSTANCE_STATE"
        
        if [ "$INSTANCE_STATE" = "STOPPED" ]; then
            echo "  🚀 Starting VM..."
            oci compute instance action --instance-id "$INSTANCE_ID" --action START --region "$REGION"
            echo "  ⏳ Waiting 120 seconds for VM to boot..."
            sleep 120
            echo "  ✅ VM started! Testing connection..."
            
            if ssh -i "$SSH_KEY" -o ConnectTimeout=10 -o StrictHostKeyChecking=no "opc@$VM_IP" "echo 'Recovery successful'" 2>/dev/null; then
                echo "  🎉 VM recovered successfully!"
                exit 0
            else
                echo "  ⚠️  VM started but SSH still fails (check security lists)"
            fi
        elif [ "$INSTANCE_STATE" = "RUNNING" ]; then
            echo "  ⚠️  VM is running but unreachable - firewall issue?"
        fi
    else
        echo "  ❌ No instance found with IP $VM_IP"
        echo "  💡 VM may have been deleted or IP changed"
    fi
else
    echo ""
    echo "[4/5] Automated Recovery: SKIPPED (OCI CLI not configured)"
fi

# Step 5: Manual recovery instructions
echo ""
echo "[5/5] Manual Recovery Required"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

if [ "$OCI_CONFIGURED" = false ]; then
    cat << 'EOF'
🔧 SETUP OCI CLI (one-time):

1. Install OCI CLI:
   bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

2. Configure OCI CLI:
   oci setup config
   
   You'll need from Oracle Console > Profile > User Settings:
   - User OCID
   - Tenancy OCID
   - Region: eu-stockholm-1
   - Generate API key (save private key)

3. Save credentials to GitHub:
   gh secret set OCI_USER_OCID --body "ocid1.user.oc1..."
   gh secret set OCI_TENANCY_OCID --body "ocid1.tenancy.oc1..."
   gh secret set OCI_FINGERPRINT --body "aa:bb:cc..."
   gh secret set OCI_PRIVATE_KEY < ~/.oci/oci_api_key.pem

4. Re-run this script

EOF
fi

cat << EOF

📋 MANUAL STEPS:

1. Open Oracle Console:
   https://cloud.oracle.com/compute/instances?region=$REGION

2. Check VM status:
   
   IF STATUS = STOPPED:
     → Click "Start" button
     → Wait 2 minutes
     → Run: ssh -i $SSH_KEY opc@$VM_IP
   
   IF STATUS = RUNNING:
     → Click instance → "Edit"
     → Add SSH key from: cat $SSH_KEY.pub
     → Save, wait 30 seconds
     → Run: ssh -i $SSH_KEY opc@$VM_IP
   
   IF NO INSTANCE FOUND:
     → VM was deleted, recreation needed:
     
     a) Copy SSH key:
        cat $SSH_KEY.pub | pbcopy
     
     b) Create new VM:
        https://cloud.oracle.com/compute/instances/create
        - Name: klarpakke-vm
        - Shape: VM.Standard.E2.1.Micro (Always Free)
        - Image: Ubuntu 22.04
        - Paste SSH key (Cmd+V)
        - Create
     
     c) Update IP in secrets:
        NEW_IP="<new-ip-from-console>"
        gh secret set ORACLE_VM_IP --body "\$NEW_IP" --repo tombomann/klarpakke
     
     d) Run deployment:
        gh workflow run one-click-deploy.yml --field action=full-deploy

3. If you cannot login to Oracle Console:
   → Password reset: https://login.oracle.com/mysso/signon.jsp
   → Contact Oracle support
   → Check email for account suspension notices

EOF

echo ""
echo "💾 Save this recovery guide:"
echo "   cat scripts/oracle-vm-recovery.sh"
echo ""
