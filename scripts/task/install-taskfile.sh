#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FATAL: $*" >&2; exit 1; }

ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
[[ -n "${ROOT:-}" ]] || die "Not inside git repo. cd /Users/taj/klarpakke først."
cd "$ROOT"

cat > Taskfile.yml << 'YAML'
version: "3"

# Task kan laste .env direkte for tasks (slipper eval/source for deploy/diagnose). [page:1]
dotenv: ['.env']

vars:
  ROOT:
    sh: git rev-parse --show-toplevel

tasks:
  doctor:
    desc: "Repo healthcheck"
    cmds:
      - cmd: bash "{{.ROOT}}/scripts/kp.sh" doctor

  # For interaktiv zsh (valgfritt): eval "$(task -s env)"
  env:
    desc: 'Print kommandoer for zsh: eval "$(task -s env)"'
    silent: true
    cmds:
      - cmd: echo "cd {{.ROOT}}"
      - cmd: echo "source scripts/make/env.sh"

  diagnose:
    desc: "Make API read-side diagnose"
    deps: [doctor]
    requires:
      vars: [MAKE_TOKEN, ORG_ID, TEAM_ID]
    cmds:
      - cmd: bash "{{.ROOT}}/scripts/make/diagnose-auth.sh"

  deploy:
    desc: "Entry: doctor -> diagnose (read-side)"
    deps: [diagnose]
    cmds:
      - cmd: echo "OK deploy (read-side)"
YAML

cat > kp << 'SH'
#!/usr/bin/env bash
set -euo pipefail
exec task "$@"
SH

chmod +x kp

echo "✅ Wrote Taskfile.yml + ./kp"
echo "NOTE: Makefile kan ignoreres videre; macOS make 3.81 støtter ikke .RECIPEPREFIX. [web:523]"
