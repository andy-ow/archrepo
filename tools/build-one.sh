#!/usr/bin/env bash
set -euo pipefail
pkgdir="${1:?podaj katalog paczki, np. packages/andrzej-tools}"
cd "$pkgdir"
makepkg -s --noconfirm
