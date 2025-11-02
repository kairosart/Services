#!/usr/bin/env bash
set -euo pipefail

# Usage: scripts/build_all_md_to_pdf.sh [output.pdf]
OUT="${1:-all-markdown.pdf}"

# Temp dir for combined markdown
TMPDIR="$(mktemp -d)"
COMBINED="$TMPDIR/combined.md"

echo "# All Markdown Files in $(basename "$(pwd)")" > "$COMBINED"
echo "" >> "$COMBINED"

# Find markdown files (sorted), excluding .git and common big directories
mapfile -t files < <(find . -type f -name '*.md' -not -path './.git/*' -not -path './node_modules/*' -not -path './.github/*' | sort)

if [ "">${#files[@]}" -eq 0 ]; then
  echo "No .md files found."
  exit 1
fi

for f in "${files[@]}"; do
  # normalize path for heading
  rel="${f#./}"
  echo "Adding: $rel" >&2
  echo -e "\n\n# $rel\n" >> "$COMBINED"

  # Append file contents, stripping YAML frontmatter (if present)
  # Uses per-file detection so frontmatter blocks are removed.
  awk 'FNR==1 && /^---$/ {in=1; next} in==1 && /^---$/ {in=0; next} in==1 {next} {print}' "$f" >> "$COMBINED"

  # page break for PDF (works with LaTeX engines)
  echo -e "\n\n\\newpage\n" >> "$COMBINED"
done

# Make sure pandoc is installed
if ! command -v pandoc >/dev/null 2>&1; then
  echo "pandoc is required but was not found. Install pandoc (and a TeX engine like xelatex) and try again."
  exit 2
fi

# Build the PDF using XeLaTeX for good font handling
pandoc "$COMBINED" -o "$OUT" --toc --pdf-engine=xelatex --metadata title="All Markdown Files"

echo "PDF generated: $OUT"