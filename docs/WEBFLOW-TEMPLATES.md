# Webflow HTML Templates

> **Slik bruker du disse templatene:**
> 1. Kopier HTML-koden nedenfor
> 2. I Webflow Designer: Legg til en **Embed**-komponent
> 3. Lim inn HTML
> 4. Publiser

---

## Global: Toast-melding

**Hvor:** Legg til på ALLE sider (f.eks. i Footer Symbol)

```html
<style>
  .kp-toast {
    position: fixed;
    bottom: 20px;
    right: 20px;
    padding: 16px 24px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 500;
    z-index: 9999;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    display: none;
  }
  .kp-toast-success {
    background: #10b981;
    color: white;
  }
  .kp-toast-error {
    background: #ef4444;
    color: white;
  }
  .kp-toast-info {
    background: #3b82f6;
    color: white;
  }
</style>

<div id="kp-toast" class="kp-toast"></div>
```

---

## Side 1: Landing (`/`)

### Hero Section

```html
<div style="max-width: 1200px; margin: 0 auto; padding: 80px 20px; text-align: center;">
  <h1 id="hero-headline" style="font-size: 48px; font-weight: 700; margin-bottom: 24px;">
    Trygg kryptotrading med AI-støtte
  </h1>
  
  <p style="font-size: 20px; color: #666; margin-bottom: 40px;">
    Lær deg risikostyring før du investerer. Ingen hype, kun trygghet.
  </p>
  
  <a href="/kalkulator" style="display: inline-block; background: #3b82f6; color: white; padding: 16px 32px; border-radius: 8px; font-weight: 600; text-decoration: none;">
    Kom i gang
  </a>
</div>
```

### Feature Cards

```html
<div style="max-width: 1200px; margin: 0 auto; padding: 60px 20px;">
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 32px;">
    
    <!-- Feature 1 -->
    <div style="padding: 32px; background: #f9fafb; border-radius: 12px;">
      <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px;">
        🛡️ Risikostyring først
      </h3>
      <p style="color: #666; line-height: 1.6;">
        Vi starter med papirhandel. Lær systemet uten risiko.
      </p>
    </div>
    
    <!-- Feature 2 -->
    <div style="padding: 32px; background: #f9fafb; border-radius: 12px;">
      <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px;">
        🤖 AI-analyse
      </h3>
      <p style="color: #666; line-height: 1.6;">
        Perplexity AI analyserer markedet hver 4. time.
      </p>
    </div>
    
    <!-- Feature 3 -->
    <div style="padding: 32px; background: #f9fafb; border-radius: 12px;">
      <h3 style="font-size: 24px; font-weight: 600; margin-bottom: 16px;">
        ⏱️ Automatisering
      </h3>
      <p style="color: #666; line-height: 1.6;">
        Du velger strategi. Systemet eksekverer.
      </p>
    </div>
    
  </div>
</div>
```

### Binance CTA (Footer)

```html
<div style="background: #f59e0b; padding: 48px 20px; text-align: center;">
  <h3 style="font-size: 28px; font-weight: 600; margin-bottom: 16px; color: white;">
    Klar til å starte?
  </h3>
  <p style="font-size: 18px; color: white; margin-bottom: 24px;">
    Opprett gratis konto hos Binance
  </p>
  <a href="#" data-kp-ref="binance" style="display: inline-block; background: white; color: #f59e0b; padding: 16px 32px; border-radius: 8px; font-weight: 600; text-decoration: none;">
    Åpne Binance-konto
  </a>
</div>
```

---

## Side 2: Pricing (`/pricing`)

```html
<div style="max-width: 1400px; margin: 0 auto; padding: 80px 20px;">
  <h1 style="text-align: center; font-size: 48px; font-weight: 700; margin-bottom: 16px;">
    Velg din plan
  </h1>
  <p style="text-align: center; font-size: 20px; color: #666; margin-bottom: 64px;">
    Alle planer er gratis. Du betaler kun exchange-avgifter.
  </p>
  
  <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(280px, 1fr)); gap: 32px;">
    
    <!-- Plan 1: Paper -->
    <div style="padding: 40px; background: white; border: 2px solid #e5e7eb; border-radius: 16px;">
      <h3 style="font-size: 28px; font-weight: 700; margin-bottom: 8px;">
        Paper
      </h3>
      <p style="font-size: 16px; color: #666; margin-bottom: 24px;">
        0 kr/måned
      </p>
      <ul style="list-style: none; padding: 0; margin-bottom: 32px;">
        <li style="padding: 8px 0; color: #374151;">✓ Papirhandel (ingen risiko)</li>
        <li style="padding: 8px 0; color: #374151;">✓ Lær systemet</li>
        <li style="padding: 8px 0; color: #374151;">✓ Ubegrenset tid</li>
      </ul>
      <button data-plan="paper" style="width: 100%; padding: 16px; background: #3b82f6; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer;">
        Start papirhandel
      </button>
    </div>
    
    <!-- Plan 2: Safe -->
    <div style="padding: 40px; background: white; border: 2px solid #10b981; border-radius: 16px; position: relative;">
      <span style="position: absolute; top: -12px; left: 50%; transform: translateX(-50%); background: #10b981; color: white; padding: 4px 16px; border-radius: 16px; font-size: 12px; font-weight: 600;">
        ANBEFALT
      </span>
      <h3 style="font-size: 28px; font-weight: 700; margin-bottom: 8px;">
        Safe
      </h3>
      <p style="font-size: 16px; color: #666; margin-bottom: 24px;">
        0 kr/måned
      </p>
      <ul style="list-style: none; padding: 0; margin-bottom: 32px;">
        <li style="padding: 8px 0; color: #374151;">✓ Maks 10% crypto-allokering</li>
        <li style="padding: 8px 0; color: #374151;">✓ Konservativ risikoprofil</li>
        <li style="padding: 8px 0; color: #374151;">✓ Stop-loss obligatorisk</li>
      </ul>
      <button data-plan="safe" style="width: 100%; padding: 16px; background: #10b981; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer;">
        Velg Safe
      </button>
    </div>
    
    <!-- Plan 3: Pro -->
    <div style="padding: 40px; background: white; border: 2px solid #e5e7eb; border-radius: 16px;">
      <h3 style="font-size: 28px; font-weight: 700; margin-bottom: 8px;">
        Pro
      </h3>
      <p style="font-size: 16px; color: #666; margin-bottom: 24px;">
        0 kr/måned
      </p>
      <ul style="list-style: none; padding: 0; margin-bottom: 32px;">
        <li style="padding: 8px 0; color: #374151;">✓ Opp til 30% crypto</li>
        <li style="padding: 8px 0; color: #374151;">✓ Moderat risiko</li>
        <li style="padding: 8px 0; color: #374151;">✓ Compounding-valg</li>
      </ul>
      <button data-plan="pro" style="width: 100%; padding: 16px; background: #3b82f6; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer;">
        Velg Pro
      </button>
    </div>
    
    <!-- Plan 4: Extrem -->
    <div style="padding: 40px; background: white; border: 2px solid #ef4444; border-radius: 16px;">
      <h3 style="font-size: 28px; font-weight: 700; margin-bottom: 8px;">
        Extrem
      </h3>
      <p style="font-size: 16px; color: #666; margin-bottom: 24px;">
        0 kr/måned
      </p>
      <ul style="list-style: none; padding: 0; margin-bottom: 32px;">
        <li style="padding: 8px 0; color: #374151;">✓ Opp til 50% crypto</li>
        <li style="padding: 8px 0; color: #374151;">⚠️ Høy risiko</li>
        <li style="padding: 8px 0; color: #374151;">⚠️ Krever opplæring</li>
      </ul>
      <button data-plan="extrem" style="width: 100%; padding: 16px; background: #ef4444; color: white; border: none; border-radius: 8px; font-weight: 600; cursor: pointer;">
        Gå til opplæring
      </button>
    </div>
    
  </div>
</div>
```

---

## Side 3: Kalkulator (`/kalkulator`)

```html
<div style="max-width: 800px; margin: 0 auto; padding: 80px 20px;">
  <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 16px;">
    Kalkulator
  </h1>
  <p style="font-size: 18px; color: #666; margin-bottom: 48px;">
    Se hva forskjellige strategier kan gi over tid.
  </p>
  
  <!-- Input Form -->
  <div style="background: #f9fafb; padding: 32px; border-radius: 12px; margin-bottom: 32px;">
    
    <!-- Startbeløp -->
    <div style="margin-bottom: 24px;">
      <label style="display: block; font-weight: 600; margin-bottom: 8px;">
        Startbeløp (NOK)
      </label>
      <input id="calc-start" type="number" value="10000" min="1000" step="1000" style="width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 16px;">
    </div>
    
    <!-- Crypto-prosent -->
    <div style="margin-bottom: 24px;">
      <label style="display: block; font-weight: 600; margin-bottom: 8px;">
        Crypto-allokering: <span id="crypto-percent-label" style="color: #3b82f6;">10%</span>
      </label>
      <input id="calc-crypto-percent" type="range" min="0" max="50" value="10" step="1" style="width: 100%;">
    </div>
    
    <!-- Plan -->
    <div style="margin-bottom: 24px;">
      <label style="display: block; font-weight: 600; margin-bottom: 8px;">
        Strategi
      </label>
      <select id="calc-plan" style="width: 100%; padding: 12px; border: 1px solid #d1d5db; border-radius: 8px; font-size: 16px;">
        <option value="paper">Paper (0% risiko)</option>
        <option value="safe" selected>Safe (maks 10%)</option>
        <option value="pro">Pro (maks 30%)</option>
        <option value="extrem">Extrem (maks 50%)</option>
      </select>
    </div>
    
  </div>
  
  <!-- Resultat -->
  <div id="calc-result-table" style="background: white; padding: 32px; border: 2px solid #e5e7eb; border-radius: 12px;">
    <p style="text-align: center; color: #9ca3af;">
      Juster verdiene over for å se prognoser
    </p>
  </div>
  
  <!-- Disclaimer -->
  <p style="margin-top: 24px; font-size: 14px; color: #9ca3af; text-align: center;">
    Dette er en forenklet kalkulator. Faktisk avkastning avhenger av markedsforhold. Historisk avkastning er ingen garanti for fremtidig avkastning.
  </p>
</div>

<script>
// Update label when slider moves
document.getElementById('calc-crypto-percent').addEventListener('input', (e) => {
  document.getElementById('crypto-percent-label').textContent = e.target.value + '%';
});
</script>
```

---

## Side 4: Dashboard (`/app/dashboard`)

```html
<div style="max-width: 1200px; margin: 0 auto; padding: 80px 20px;">
  <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 48px;">
    Dashboard
  </h1>
  
  <div id="signals-container" style="display: grid; gap: 24px;">
    <p style="text-align: center; color: #9ca3af; padding: 64px 20px;">
      Ingen aktive signaler akkurat nå.
    </p>
  </div>
</div>

<style>
.signal-card {
  background: white;
  border: 2px solid #e5e7eb;
  border-radius: 12px;
  padding: 24px;
  display: grid;
  grid-template-columns: 1fr auto;
  gap: 16px;
  align-items: center;
}

.signal-card h3 {
  margin: 0 0 8px 0;
  font-size: 24px;
  font-weight: 700;
}

.signal-card p {
  margin: 4px 0;
  color: #666;
}

.btn-approve, .btn-reject {
  padding: 12px 24px;
  border: none;
  border-radius: 8px;
  font-weight: 600;
  cursor: pointer;
  margin-left: 8px;
}

.btn-approve {
  background: #10b981;
  color: white;
}

.btn-reject {
  background: #ef4444;
  color: white;
}
</style>
```

---

## Side 5: Settings (`/app/settings`)

```html
<div style="max-width: 800px; margin: 0 auto; padding: 80px 20px;">
  <h1 style="font-size: 48px; font-weight: 700; margin-bottom: 48px;">
    Innstillinger
  </h1>
  
  <div style="background: #f9fafb; padding: 32px; border-radius: 12px;">
    
    <!-- Plan Selection -->
    <div style="margin-bottom: 32px;">
      <label style="display: block; font-weight: 600; margin-bottom: 12px; font-size: 18px;">
        Strategi
      </label>
      <select id="plan-select" style="width: 100%; padding: 16px; border: 2px solid #d1d5db; border-radius: 8px; font-size: 16px;">
        <option value="paper">Paper (papirhandel)</option>
        <option value="safe">Safe (maks 10% crypto)</option>
        <option value="pro">Pro (maks 30% crypto)</option>
        <option value="extrem">Extrem (maks 50% crypto)</option>
      </select>
    </div>
    
    <!-- Compounding Toggle -->
    <div style="margin-bottom: 32px;">
      <label style="display: flex; align-items: center; cursor: pointer;">
        <input id="compound-toggle" type="checkbox" checked style="width: 24px; height: 24px; margin-right: 12px; cursor: pointer;">
        <span style="font-weight: 600; font-size: 18px;">Aktiver compounding</span>
      </label>
      <p style="margin-top: 8px; color: #666; font-size: 14px;">
        Reinvester gevinster automatisk for eksponensiell vekst
      </p>
    </div>
    
    <!-- Save Button -->
    <button id="save-settings" style="width: 100%; padding: 16px; background: #3b82f6; color: white; border: none; border-radius: 8px; font-weight: 600; font-size: 18px; cursor: pointer;">
      Lagre innstillinger
    </button>
    
  </div>
</div>
```

---

## CSS Utilities (legg til i Project Settings → Custom Code → Head)

```html
<style>
/* Klarpakke Global Styles */
* {
  box-sizing: border-box;
}

button:hover {
  opacity: 0.9;
  transform: translateY(-2px);
  transition: all 0.2s;
}

button:active {
  transform: translateY(0);
}

a {
  transition: all 0.2s;
}

a:hover {
  opacity: 0.9;
}
</style>
```

---

## 🚨 VIKTIG: Husk etter at du har limt inn HTMLen

1. **Publiser til staging**
2. **Test i browser med DevTools → Console**
3. **Se etter `[Klarpakke] Initialized` i Console**
4. **Test alle knapper og inputs**
5. **Verifiser at API-kall fungerer (Network-tab)**

---

## Når du er klar for produksjon

```bash
cd ~/klarpakke
npm run gen:webflow-production  # Generer prod loader (debug: false)
```

Lim inn den nye loaderen i Webflow Custom Code og publiser til prod-domene.
