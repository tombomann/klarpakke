<script>
(function() {
  "use strict";
  window.KLARPAKKE_CONFIG = {
    supabaseUrl: "",
    supabaseAnonKey: "",
    version: "1.0.0",
    debug: false
  };
  console.log("[Klarpakke] Config loaded", window.KLARPAKKE_CONFIG.version);
  const CDN = "https://cdn.jsdelivr.net/gh/tombomann/klarpakke@main/web/dist";
  function loadScript(src, name) {
    const s = document.createElement("script");
    s.src = src;
    s.async = true;
    s.onload = () => console.log("[Klarpakke] ✅ " + name);
    s.onerror = () => console.error("[Klarpakke] ❌ Failed: " + name);
    document.body.appendChild(s);
  }
  loadScript(CDN + "/klarpakke-site.js", "Main");
  if (window.location.pathname.includes("/kalkulator")) {
    loadScript(CDN + "/calculator.js", "Calculator");
  }
})();
</script>
