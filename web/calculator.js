// Klarpakke Calculator (Compound Interest)
// Paste this in Webflow: Page Settings > Custom Code > Before </body>

(function() {
  'use strict';

  // Config: Realistic annual returns per plan
  const PLANS = {
    paper: { name: 'Gratis (Paper)', annual: 0, color: '#4CAF50' },
    safe: { name: 'SAFE $49', annual: 0.10, color: '#4CAF50' },
    pro: { name: 'PRO $99', annual: 0.15, color: '#FFC107' },
    extrem: { name: 'EXTREM $199', annual: 0.25, color: '#111827' }
  };

  // Get elements (adjust selectors to match your Webflow structure)
  const startInput = document.getElementById('calc-start');
  const cryptoSlider = document.getElementById('calc-crypto-percent');
  const planSelect = document.getElementById('calc-plan');
  const resultTable = document.getElementById('calc-result-table');
  const cryptoLabel = document.getElementById('crypto-percent-label');

  if (!startInput || !cryptoSlider || !planSelect || !resultTable) {
    console.warn('Calculator elements not found. Check IDs.');
    return;
  }

  // Update label when slider changes
  cryptoSlider.addEventListener('input', function() {
    if (cryptoLabel) {
      cryptoLabel.textContent = cryptoSlider.value + '%';
    }
    calculate();
  });

  startInput.addEventListener('input', calculate);
  planSelect.addEventListener('change', calculate);

  function calculate() {
    const startAmount = parseFloat(startInput.value) || 5000;
    const cryptoPercent = parseFloat(cryptoSlider.value) || 50;
    const planKey = planSelect.value || 'pro';
    const plan = PLANS[planKey];

    const cryptoAmount = startAmount * (cryptoPercent / 100);
    const cashAmount = startAmount - cryptoAmount;

    // Calculate compound interest for 1, 3, 5 years
    const results = [1, 3, 5].map(years => {
      const cryptoFuture = cryptoAmount * Math.pow(1 + plan.annual, years);
      const total = cryptoFuture + cashAmount;
      const growth = ((total - startAmount) / startAmount * 100).toFixed(1);
      return {
        years,
        total: formatUSD(total),
        growth: growth + '%'
      };
    });

    // Render table
    let html = '<table style="width:100%; border-collapse: collapse; margin-top: 1rem;">';
    html += '<thead><tr style="border-bottom: 2px solid #E5E7EB;">';
    html += '<th style="padding: 0.75rem; text-align: left;">Tidsperiode</th>';
    html += '<th style="padding: 0.75rem; text-align: left;">Anslått verdi</th>';
    html += '<th style="padding: 0.75rem; text-align: left;">Vekst</th>';
    html += '</tr></thead><tbody>';

    results.forEach((r, i) => {
      const emoji = i === 0 ? '📈' : i === 1 ? '🚀' : '🎯';
      html += '<tr style="border-bottom: 1px solid #E5E7EB;">';
      html += `<td style="padding: 0.75rem;">${r.years} år</td>`;
      html += `<td style="padding: 0.75rem; font-weight: 600;">${r.total}</td>`;
      html += `<td style="padding: 0.75rem; color: ${plan.color};">${r.growth} ${emoji}</td>`;
      html += '</tr>';
    });

    html += '</tbody></table>';
    resultTable.innerHTML = html;
  }

  function formatUSD(amount) {
    return '$' + amount.toLocaleString('en-US', { maximumFractionDigits: 0 });
  }

  // Initial calculation
  calculate();
})();
