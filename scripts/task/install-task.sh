#!/usr/bin/env bash
set -euo pipefail

die(){ echo "FATAL: $*" >&2; exit 1; }

if command -v task >/dev/null 2>&1; then
  echo "✅ task already installed: $(task --version || true)"
  exit 0
fi

os="$(uname -s | tr '[:upper:]' '[:lower:]')"

if [[ "$os" == "darwin" ]]; then
  if command -v brew >/dev/null 2>&1; then
    brew install go-task/tap/go-task
    task --version
    exit 0
  fi
  die "Homebrew mangler. Installer brew eller installer task manuelt."
fi

if [[ "$os" == "linux" ]]; then
  die "Linux install: velg pakkehåndtering (snap/apt) eller installer fra upstream. Se https://taskfile.dev"
fi

die "Unsupported OS: $os"
