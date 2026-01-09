#!/usr/bin/env bash
set -euo pipefail
pkgdir="${1:?podaj katalog paczki, np. packages/andrzej-tools}"
cd "$pkgdir"

rm -rf src/ pkg/
rm -f *.pkg.tar* *.log *.sig
rm -f .BUILDINFO .PKGINFO .MTREE 2>/dev/null || true
echo "OK: wyczyszczono artefakty w $pkgdir"