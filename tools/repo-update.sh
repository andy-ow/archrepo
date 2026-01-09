#!/usr/bin/env bash
set -euo pipefail

REPONAME="${REPONAME:-andy}"
ARCH="${ARCH:-x86_64}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$ROOT/repo/$ARCH"

mkdir -p "$REPO_DIR"

# 1) znajdź wszystkie paczki z packages/* (2 poziomy), niezależnie od PKGEXT
mapfile -d '' PKGS < <(
  find "$ROOT/packages" -maxdepth 2 -type f \
    \( -name '*.pkg.tar' -o -name '*.pkg.tar.*' \) \
    ! -name '*.sig' -print0
)

if (( ${#PKGS[@]} == 0 )); then
  echo "ERROR: Nie znaleziono żadnych paczek w $ROOT/packages (zrób najpierw build)."
  exit 1
fi

# 2) skopiuj do repo/x86_64 (tylko jeśli nowsze)
for p in "${PKGS[@]}"; do
  cp -u "$p" "$REPO_DIR/"
done

# 3) zaktualizuj bazę repo
cd "$REPO_DIR"

mapfile -d '' REPO_PKGS < <(
  find . -maxdepth 1 -type f \
    \( -name '*.pkg.tar' -o -name '*.pkg.tar.*' \) \
    ! -name '*.sig' -print0
)

if (( ${#REPO_PKGS[@]} == 0 )); then
  echo "ERROR: W $REPO_DIR nie ma paczek po skopiowaniu (to nie powinno się zdarzyć)."
  exit 1
fi

repo-add "${REPONAME}.db.tar.gz" "${REPO_PKGS[@]}"
echo "OK: Zaktualizowano repo: $REPO_DIR (${#REPO_PKGS[@]} paczek)"
