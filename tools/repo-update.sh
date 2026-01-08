#!/usr/bin/env bash
set -euo pipefail

REPONAME="${REPONAME:-andy}"
ARCH="${ARCH:-x86_64}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_DIR="$ROOT/repo/$ARCH"

mkdir -p "$REPO_DIR"

# Kopiuj wszystkie paczki z packages/* (max 2 poziomy)
find "$ROOT/packages" -maxdepth 2 -name "*.pkg.tar.zst" -type f -print0 \
  | xargs -0 -I{} cp -u "{}" "$REPO_DIR/"

cd "$REPO_DIR"
repo-add "${REPONAME}.db.tar.gz" ./*.pkg.tar.zst
