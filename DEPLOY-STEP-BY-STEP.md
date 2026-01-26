# 📋 Supabase Deployment - Step by Step

## Problem
Supabase SQL Editor kan kjøre bare DELER av SQL-filen hvis du ikke marker alt.

## Løsning: Følg disse stegene NØYAKTIG

### Steg 1: Copy SQL
```bash
cat DEPLOY-NOW.sql | pbcopy
```

### Steg 2: Åpne Supabase SQL Editor
```bash
open "https://supabase.com/dashboard/project/swfyuwkptusceiouqlks/editor"
```

### Steg 3: I SQL Editor (KRITISK!)

1. ✅ Klikk "New query" (topp venstre)
2. ✅ Paste SQL med `CMD+V`
3. ✅ **MERK ALT**: `CMD+A` (hele SQL-filen skal være highlighted i blått)
4. ✅ Klikk **RUN** (eller trykk `CMD+ENTER`)

**VIKTIG**: Hvis du ikke marker alt (CMD+A), kjøres bare linjen cursoren står på!

### Steg 4: Sjekk resultat

Du skal se i "Results":
```
Database setup complete!
Tables created: positions, signals, daily_risk_meter, ai_calls
```

### Steg 5: VERIFISER at tabellene faktisk ble opprettet

Kjør denne SQL (i samme editor):

```sql
SELECT tablename 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('positions', 'signals', 'daily_risk_meter', 'ai_calls')
ORDER BY tablename;
```

Du skal se **4 rader**:
- ai_calls
- daily_risk_meter
- positions
- signals

### Steg 6: Test fra terminal

```bash
bash scripts/smoke-test.sh
```

Skal vise:
- ✅ All 4 tables exist
- ✅ INSERT works
- ✅ SELECT works

---

## Hvis det fortsatt ikke fungerer

Kjør SQL linje-for-linje via dette scriptet:

```bash
bash scripts/deploy-line-by-line.sh
```
