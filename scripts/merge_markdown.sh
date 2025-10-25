#!/usr/bin/env bash
# Robust Markdown merger that handles spaces/newlines in filenames.
# Usage: ./scripts/merge_markdown.sh [output-file]
set -euo pipefail

OUT="${1:-MERGED.md}"

# Start fresh
: > "$OUT"

# If this is a git repo, prefer git ls-files (keeps tracked-file ordering)
if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  # List tracked .md files (null-separated), loop safely
  git ls-files -z -- '*.md' | while IFS= read -r -d '' file; do
    [ "$file" = "$OUT" ] && continue
    printf "\n\n<!-- file: %s -->\n\n" "$file" >> "$OUT"
    cat "$file" >> "$OUT"
  done
else
  # Fallback: find all .md files (excluding .git), sort (if GNU sort available), loop safely
  find . -type f -name '*.md' -not -path './.git/*' -print0 \
    | ( if command -v sort >/dev/null 2>&1; then sort -z; else cat; fi ) \
    | while IFS= read -r -d '' file; do
      # strip leading ./ for nicer header
      header="${file#./}"
      [ "$header" = "$OUT" ] && continue
      printf "\n\n<!-- file: %s -->\n\n" "$header" >> "$OUT"
      cat "$file" >> "$OUT"
    done
fi

printf "\n\nMerged into %s\n" "$OUT"