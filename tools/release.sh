#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# 1) build paczki (tu możesz dodać więcej paczek, jak będą)
"$ROOT/tools/build-one.sh" "$ROOT/packages/andrzej-tools"

# 2) update lokalnego repo
"$ROOT/tools/repo-update.sh"

# 3) publish pages (token opcjonalny)
if [[ -n "${GITHUB_TOKEN_FILE:-}" ]]; then
  "$ROOT/tools/publish-pages.sh"
else
  "$ROOT/tools/publish-pages.sh"
fi
