#!/usr/bin/env bash
set -euo pipefail
die(){ echo "FATAL: $*" >&2; exit 1; }

ENV_FILE="${ENV_FILE:-.env}"
test -f "$ENV_FILE" || die "Mangler $ENV_FILE"

ts="$(date +%Y%m%d-%H%M%S)"
cp "$ENV_FILE" "$ENV_FILE.bak-$ts"

printf "Lim inn FULL Make API token (skjules ved input): "
IFS= read -r -s token
echo
test -n "${token:-}" || die "Tom token"

python3 - "$ENV_FILE" "$token" << 'PY'
import sys, re
path=sys.argv[1]; token=sys.argv[2]

# enkel guard: fjern evt. \r fra copy/paste
token=token.replace("\r","")

with open(path,"r",encoding="utf-8") as f:
    lines=f.read().splitlines()

out=[]
found=False
for line in lines:
    if re.match(r"^\s*MAKE_TOKEN\s*=", line):
        out.append("MAKE_TOKEN="+token)
        found=True
    else:
        out.append(line)

if not found:
    out.append("MAKE_TOKEN="+token)

with open(path,"w",encoding="utf-8",newline="\n") as f:
    f.write("\n".join(out).rstrip()+"\n")
print(f"OK: updated {path} (MAKE_TOKEN replaced)")
PY

echo "OK: wrote $ENV_FILE (backup: $ENV_FILE.bak-$ts)"
