#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WT="$ROOT/.worktree-ghpages"

# gdzie jest token (plik ma zawierać sam token w 1 linii)
TOKEN_FILE="${GITHUB_TOKEN_FILE:-}"
GITHUB_USER="${GITHUB_USER:-x-access-token}"

# upewnij się że worktree istnieje (worktree ma .git często jako plik)
if [[ ! -e "$WT/.git" ]]; then
  # jeśli katalog istnieje, ale nie jest worktree, usuń go (żeby worktree add nie wywalił)
  if [[ -e "$WT" ]]; then
    rm -rf "$WT"
  fi
  git -C "$ROOT" worktree add "$WT" gh-pages
fi

# GitHub Pages lubi mieć .nojekyll (bezpieczne)
touch "$WT/.nojekyll"

# publikujemy: repo/ -> gh-pages: arch/
mkdir -p "$WT/arch"
rsync -a --delete "$ROOT/repo/" "$WT/arch/"

cd "$WT"
git add -A
git commit -m "Update pacman repo" || true

# push (jeśli origin jest SSH – pójdzie bez tokena; jeśli HTTPS i chcesz token – użyj askpass)
if [[ -n "$TOKEN_FILE" ]]; then
  # bezpieczniej niż wkładanie tokena w URL (nie pojawia się w ps)
  tmp="$(mktemp)"
  chmod 700 "$tmp"
  cat >"$tmp" <<'EOF'
#!/bin/sh
case "$1" in
  *Username*) echo "${GITHUB_USER:-x-access-token}" ;;
  *Password*) cat "$GITHUB_TOKEN_FILE" ;;
  *) cat "$GITHUB_TOKEN_FILE" ;;
esac
EOF
  cleanup() { rm -f "$tmp"; }
  trap cleanup EXIT

  export GIT_ASKPASS="$tmp"
  export GIT_TERMINAL_PROMPT=0
  export GITHUB_TOKEN_FILE
  export GITHUB_USER
  git push origin gh-pages
  unset GIT_ASKPASS GIT_TERMINAL_PROMPT
else
  git push origin gh-pages
fi
