#!/usr/bin/env bash
set -euo pipefail

REPONAME="${REPONAME:-andy}"
ARCH="${ARCH:-x86_64}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$ROOT/repo/$ARCH"

mkdir -p "$REPO_DIR"

# 1) skopiuj wszystkie zbudowane paczki do repo/
mapfile -d '' PKGS < <(
  find "$ROOT/packages" -maxdepth 2 -type f \
    \( -name '*.pkg.tar' -o -name '*.pkg.tar.*' \) \
    ! -name '*.sig' -print0
)
if (( ${#PKGS[@]} == 0 )); then
  echo "ERROR: brak paczek w $ROOT/packages (najpierw build)."
  exit 1
fi
for p in "${PKGS[@]}"; do
  cp -u "$p" "$REPO_DIR/"
done

cd "$REPO_DIR"

# 2) wyczyść stare bazy (żeby nie było błędów 'file not found')
rm -f "${REPONAME}.db.tar.gz" "${REPONAME}.files.tar.gz" \
      "${REPONAME}.db.tar.gz.old" "${REPONAME}.files.tar.gz.old"
rm -rf "${REPONAME}.db" "${REPONAME}.files"

# 3) zbuduj bazę na podstawie paczek, które realnie są w repo/
mapfile -d '' REPO_PKGS < <(
  find . -maxdepth 1 -type f \
    \( -name '*.pkg.tar' -o -name '*.pkg.tar.*' \) \
    ! -name '*.sig' -print0
)
repo-add "${REPONAME}.db.tar.gz" "${REPO_PKGS[@]}"

echo "OK: Rebuilt repo db in $REPO_DIR (${#REPO_PKGS[@]} paczek)"
