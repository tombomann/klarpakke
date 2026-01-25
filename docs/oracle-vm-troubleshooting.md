# Oracle VM Troubleshooting & Recovery Guide

## Problem: Cannot Login to Oracle Cloud Console

Hvis du ikke klarer å logge inn manuelt på Oracle Cloud Console, følg denne guiden.

### ⚠️ Symptomer

- SSH timeout: `ssh: connect to host 129.151.201.41 port 22: Operation timed out`
- Ping failed: `100% packet loss`
- DNS ikke oppdatert: `dig api.klarpakke.no` returnerer ingenting
- Kan ikke logge inn på [Oracle Cloud Console](https://cloud.oracle.com)

### 🔍 Root Causes (mulige årsaker)

1. **Oracle Account Issues**
   - Passord utgått eller glemt
   - Multi-factor authentication (MFA) problemer
   - Account suspended (gratis tier limits overskredet)
   - Feil identity domain

2. **VM Issues**
   - VM stoppet (STOPPED state)
   - VM slettet (Always Free tier cleanup)
   - Firewall/security list blokkerer SSH
   - IP-adresse endret

3. **Nettverksproblemer**
   - Oracle Cloud infrastructure issues
   - DNS ikke propagert
   - Lokal firewall blokkerer utgående SSH

---

## 🚪 Løsning 1: Automatisk Recovery via GitHub Actions

**Forutsetning:** OCI API credentials må være satt opp (se Løsning 2)

### Kjør Recovery Workflow

1. Gå til [Oracle VM Recovery Workflow](https://github.com/tombomann/klarpakke/actions/workflows/oracle-vm-recovery.yml)

2. Klikk **"Run workflow"**

3. Velg action:
   - `diagnose` - Sjekk VM status (safe, ingen endringer)
   - `start-vm` - Start VM hvis den er stoppet
   - `full-recovery` - Full diagnose + start + test

4. Klikk **"Run workflow"**

5. Vent 2-3 minutter, sjekk loggene

**Fordeler:**
- Ingen manual login til Oracle nødvendig
- Automatisk diagnostikk
- Kan kjøres fra mobil/nettbrett

---

## 🔧 Løsning 2: Setup OCI CLI (Engangsoppsett)

For å enable automatisk recovery MÅ du først sette opp Oracle Cloud Infrastructure (OCI) API credentials.

### Steg 1: Få tilgang til Oracle Console (alternative metoder)

#### Metode A: Password Reset
1. Gå til https://login.oracle.com/mysso/signon.jsp
2. Klikk "Forgot Password?"
3. Følg instruksjoner i email
4. Logg inn med nytt passord

#### Metode B: Browser Autocomplete
1. Åpne Oracle Console link i nettleser som du brukte tidligere
2. La nettleseren auto-fylle passord hvis lagret
3. Prøv alle lagrede credentials

#### Metode C: Check Email for Account Notices
1. Søk i email etter "Oracle Cloud"
2. Se etter:
   - Account suspension notices
   - Always Free tier warnings
   - Password reset emails
   - Welcome emails (inneholder identity domain info)

#### Metode D: Contact Oracle Support
1. Gå til https://support.oracle.com
2. Chat support (24/7)
3. Ha klar: Email, Tenancy Name, Cloud Account Name

### Steg 2: Hent OCI API Credentials

Når du har tilgang til Oracle Console:

1. **Gå til User Settings:**
   ```
   https://cloud.oracle.com/identity/domains/my-profile/details?region=eu-stockholm-1
   ```

2. **Kopier User OCID:**
   - Klikk "Show" ved siden av "OCID"
   - Kopier verdien (starter med `ocid1.user.oc1...`)
   - Lagre i notater

3. **Finn Tenancy OCID:**
   - Klikk hamburger-menyen (☰) øverst til venstre
   - "Governance & Administration" → "Tenancy Details"
   - Kopier "OCID" (starter med `ocid1.tenancy.oc1...`)
   - Lagre i notater

4. **Generer API Key:**
   ```bash
   # Kjør på din Mac
   mkdir -p ~/.oci
   openssl genrsa -out ~/.oci/oci_api_key.pem 2048
   chmod 600 ~/.oci/oci_api_key.pem
   openssl rsa -pubout -in ~/.oci/oci_api_key.pem -out ~/.oci/oci_api_key_public.pem
   
   # Kopier public key
   cat ~/.oci/oci_api_key_public.pem | pbcopy
   echo "✅ Public key copied to clipboard"
   ```

5. **Upload API Key til Oracle:**
   - Tilbake i Oracle Console → User Settings
   - Scroll ned til "API Keys"
   - Klikk "Add API Key"
   - Velg "Paste Public Key"
   - Paste (Cmd+V) nøkkelen du kopierte
   - Klikk "Add"
   - **VIKTIG:** Kopier "Fingerprint" (f.eks. `aa:bb:cc:dd:...`)

### Steg 3: Lagre Credentials i GitHub Secrets

```bash
# Fra terminal på Mac
cd ~/klarpakke

# User OCID (fra steg 2)
gh secret set OCI_USER_OCID \
  --body "ocid1.user.oc1...<din-user-ocid>" \
  --repo tombomann/klarpakke

# Tenancy OCID (fra steg 2)
gh secret set OCI_TENANCY_OCID \
  --body "ocid1.tenancy.oc1...<din-tenancy-ocid>" \
  --repo tombomann/klarpakke

# Fingerprint (fra steg 2)
gh secret set OCI_FINGERPRINT \
  --body "aa:bb:cc:dd:ee:ff:00:11:22:33:44:55:66:77:88:99" \
  --repo tombomann/klarpakke

# Private Key (fra steg 2)
gh secret set OCI_PRIVATE_KEY \
  --repo tombomann/klarpakke < ~/.oci/oci_api_key.pem

echo "✅ All OCI credentials saved to GitHub"
```

### Steg 4: Test OCI CLI Lokalt (optional)

```bash
# Install OCI CLI
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"

# Configure
oci setup config
# Svar:
# - Location for config: ~/.oci/config
# - User OCID: <din user ocid>
# - Tenancy OCID: <din tenancy ocid>
# - Region: eu-stockholm-1
# - Generate new RSA key pair? N
# - Private key location: ~/.oci/oci_api_key.pem

# Test
oci iam region list
# Skal liste alle Oracle regions

# List instances
oci compute instance list --compartment-id "$(oci iam compartment list --query 'data[0].id' --raw-output)" --region eu-stockholm-1
```

### Steg 5: Kjør Recovery

Nå kan du bruke **Løsning 1** (GitHub Actions workflow) for automatisk recovery.

---

## 🛠️ Løsning 3: Lokal Recovery Script

```bash
cd ~/klarpakke
git pull

# Make script executable
chmod +x scripts/oracle-vm-recovery.sh

# Run recovery
./scripts/oracle-vm-recovery.sh
```

Scriptet vil:
1. Teste nettverkstilkobling til VM
2. Sjekke om OCI CLI er konfigurert
3. Liste alle VM instances
4. Starte VM automatisk hvis stoppet
5. Gi manuelle instruksjoner hvis nødvendig

---

## 🚨 Emergency: VM Slettet (Manual Recreate)

Hvis VM er slettet permanent (Always Free cleanup):

### 1. Generer ny SSH key (hvis nødvendig)

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/oracle_new -C "klarpakke-vm"
cat ~/.ssh/oracle_new.pub | pbcopy
echo "✅ SSH public key copied"
```

### 2. Opprett ny VM i Oracle Console

1. Gå til https://cloud.oracle.com/compute/instances/create?region=eu-stockholm-1

2. **Placement:**
   - Availability domain: (keep default)

3. **Image and shape:**
   - Image: Canonical Ubuntu 22.04 (default)
   - Shape: VM.Standard.E2.1.Micro (Always Free Eligible)
   - Click "Change Shape" hvis ikke vist

4. **Networking:**
   - Virtual cloud network: Bruk eksisterende VCN
   - Subnet: Public subnet (default)
   - Assign a public IPv4 address: ✅ Checked

5. **Add SSH keys:**
   - Paste public keys: ✅ Selected
   - SSH keys: Paste fra clipboard (Cmd+V)

6. **Boot volume:**
   - Keep defaults (50 GB)

7. Klikk **"Create"**

8. Vent 2-3 minutter til Status = RUNNING

9. **Kopier ny IP-adresse** (f.eks. `130.61.x.x`)

### 3. Oppdater GitHub Secrets + DNS

```bash
NEW_IP="130.61.x.x"  # Replace med faktisk IP

# Update GitHub secret
gh secret set ORACLE_VM_IP --body "$NEW_IP" --repo tombomann/klarpakke

# Update DNS (optional - kan også bruke GitHub workflow)
curl -X POST "https://api.domeneshop.no/v0/domains/2187405/dns" \
  -u "$DOMENESHOP_USER:$DOMENESHOP_KEY" \
  -H "Content-Type: application/json" \
  -d '{"host":"api","ttl":3600,"type":"A","data":"'"$NEW_IP"'"}'

echo "✅ IP updated"
```

### 4. Test SSH Connection

```bash
ssh -i ~/.ssh/oracle_new opc@$NEW_IP

# Hvis vellykket:
sudo apt update && echo "✅ VM accessible!"
exit
```

### 5. Deploy Backend

```bash
# Via GitHub Actions
gh workflow run one-click-deploy.yml --field action=full-deploy

# Vent 2 min, test:
curl http://api.klarpakke.no
```

---

## 📃 Troubleshooting Checklist

- [ ] Kan ikke logge inn på Oracle Console
  - [ ] Prøvd password reset
  - [ ] Sjekket email for account notices
  - [ ] Prøvd alternative browsers/devices
  - [ ] Kontaktet Oracle support

- [ ] VM unreachable (ping/SSH timeout)
  - [ ] Kjørt `diagnose` GitHub workflow
  - [ ] Sjekket VM status i Oracle Console (hvis tilgjengelig)
  - [ ] Testet fra annet nettverk (mobil hotspot)

- [ ] VM finnes men SSH fails
  - [ ] Verifisert SSH key er lagt til i Oracle Console
  - [ ] Sjekket Security Lists (port 22 åpen?)
  - [ ] Testet `ssh -vvv` for debug output

- [ ] DNS issues
  - [ ] Kjørt `dig api.klarpakke.no +short`
  - [ ] Vent 5-10 min for DNS propagation
  - [ ] Testet direkte IP: `curl http://<IP>`

---

## 📞 Support

**Oracle Cloud Free Tier Support:**
- Chat: https://support.oracle.com (24/7)
- Forum: https://community.oracle.com/customerconnect/categories/oci-free-tier

**Klarpakke Project:**
- GitHub Issues: https://github.com/tombomann/klarpakke/issues
- Workflow Logs: https://github.com/tombomann/klarpakke/actions

---

## 📚 Referanser

- [Oracle Cloud Console](https://cloud.oracle.com)
- [OCI CLI Installation](https://docs.oracle.com/en-us/iaas/Content/API/SDKDocs/cliinstall.htm)
- [OCI API Key Setup](https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm)
- [Always Free Tier Limits](https://docs.oracle.com/en-us/iaas/Content/FreeTier/freetier_topic-Always_Free_Resources.htm)
