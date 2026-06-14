#!/usr/bin/env bash
# Keep sensible ignore rules in place for whatever stack is in use, inside a
# managed block so the user's own additions are never touched.
# Usage: update-gitignore.sh <stack>...   e.g. update-gitignore.sh node python

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=lib/common.sh
source "$HERE/lib/common.sh"

root="$(project_root 2>/dev/null || echo "$PWD")"
file="$root/.gitignore"
BEGIN="# === gitless keeps these tidy (safe to ignore) ==="
END="# === end gitless ==="

patterns_for() {
  case "$1" in
    base)   printf '%s\n' '.worktrees/' '.DS_Store' 'Thumbs.db' '*.log' '.env' '.env.*' '.cache/' 'tmp/' ;;
    node)   printf '%s\n' 'node_modules/' 'dist/' 'build/' '.next/' '.turbo/' 'npm-debug.log*' '.pnpm-store/' ;;
    python) printf '%s\n' '__pycache__/' '*.pyc' '.venv/' 'venv/' '.pytest_cache/' '.mypy_cache/' '*.egg-info/' '.ipynb_checkpoints/' ;;
    rust)   printf '%s\n' 'target/' 'Cargo.lock' ;;
    go)     printf '%s\n' 'bin/' '*.exe' '*.test' '*.out' ;;
    java)   printf '%s\n' 'target/' '*.class' '.gradle/' 'build/' ;;
    *)      ;;  # unknown stack: nothing to add
  esac
}

touch "$file"

# Read whatever is already inside the managed block so we stay cumulative.
managed=""
if grep -qF "$BEGIN" "$file"; then
  managed="$(awk -v b="$BEGIN" -v e="$END" '$0==b{f=1;next} $0==e{f=0} f' "$file")"
fi

add_line() { case $'\n'"$managed"$'\n' in *$'\n'"$1"$'\n'*) ;; *) managed="${managed:+$managed$'\n'}$1";; esac; }

# Always ensure base rules, then anything requested.
while IFS= read -r p; do add_line "$p"; done < <(patterns_for base)
for stack in "$@"; do
  while IFS= read -r p; do [ -n "$p" ] && add_line "$p"; done < <(patterns_for "$stack")
done

# Rewrite the file with the managed block refreshed, user content preserved.
tmp="$(mktemp)"
if grep -qF "$BEGIN" "$file"; then
  awk -v b="$BEGIN" -v e="$END" '$0==b{skip=1} skip&&$0==e{skip=0;next} !skip' "$file" > "$tmp"
else
  cat "$file" > "$tmp"
fi
{ printf '%s\n' "$BEGIN"; printf '%s\n' "$managed"; printf '%s\n' "$END"; } >> "$tmp"
mv "$tmp" "$file"

info "Tidied up which files to keep out of your project's backup."
