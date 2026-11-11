#!/bin/sh
# Create an Agent LLM Wiki Vault folder layout without overwriting existing files.
# POSIX sh. No network. Safe to re-run.
#
# Usage: init-vault.sh DEST
#        init-vault.sh --templates DIR DEST

set -eu

usage() {
  echo "Usage: init-vault.sh [--templates DIR] DEST" >&2
  echo "  Create a vault at DEST from the recipe templates." >&2
  echo "  Existing files are left untouched. Directories are created as needed." >&2
  exit 2
}

TEMPLATES=""
DEST=""

while [ "$#" -gt 0 ]; do
  case "$1" in
    -h|--help)
      usage
      ;;
    --templates)
      if [ "$#" -lt 2 ]; then
        usage
      fi
      TEMPLATES="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      if [ -n "$DEST" ]; then
        echo "Too many arguments." >&2
        usage
      fi
      DEST="$1"
      shift
      ;;
  esac
done

if [ -z "$DEST" ]; then
  usage
fi

# Resolve the templates directory. Default: ../templates next to this script.
if [ -z "$TEMPLATES" ]; then
  SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
  TEMPLATES="$SCRIPT_DIR/../templates"
fi

if [ ! -d "$TEMPLATES" ]; then
  echo "Templates directory not found: $TEMPLATES" >&2
  exit 1
fi

# Refuse to write through an existing symlink for DEST itself if it already exists as a symlink
# to somewhere unexpected — we still allow creating a new path. Normalize DEST after mkdir.
if [ -e "$DEST" ] && [ ! -d "$DEST" ]; then
  echo "DEST exists and is not a directory: $DEST" >&2
  exit 1
fi

mkdir -p "$DEST"
DEST=$(CDPATH= cd -- "$DEST" && pwd)
TEMPLATES=$(CDPATH= cd -- "$TEMPLATES" && pwd)

# Starter files at the vault root.
ROOT_FILES="SCHEMA.md AGENTS.md index.md log.md lint-checklist.md"

# Folder layout from the article, plus Hermes llm-wiki folders (comparisons, queries, raw subfolders).
DIRS="
raw/articles
raw/papers
raw/transcripts
raw/assets
entities
concepts
comparisons
queries
research
decisions
dreams
daily
_archive
_templates
"

created_dirs=0
created_files=0
skipped_files=0

for rel in $DIRS; do
  path="$DEST/$rel"
  if [ ! -d "$path" ]; then
    mkdir -p "$path"
    created_dirs=$((created_dirs + 1))
    echo "created dir  $rel"
  fi
done

# Today's date, portable: prefer date -u +%Y-%m-%d, then date +%Y-%m-%d.
TODAY=$(date +%Y-%m-%d 2>/dev/null || true)
if [ -z "$TODAY" ]; then
  TODAY="YYYY-MM-DD"
fi

copy_no_clobber() {
  src="$1"
  dst="$2"
  label="$3"
  subst="${4:-}"

  if [ -e "$dst" ]; then
    skipped_files=$((skipped_files + 1))
    echo "skipped      $label (already exists)"
    return 0
  fi

  if [ ! -f "$src" ]; then
    echo "missing template: $src" >&2
    exit 1
  fi

  # Copy via a temp file in the destination directory, then mv. No overwrite: dest must not exist.
  tmp="$dst.init-vault.tmp.$$"
  if [ -n "$subst" ]; then
    # Replace {{DATE}} only. Keep the rest byte-stable aside from that token.
    # Use awk for portability (no GNU sed assumed).
    TODAY="$TODAY" awk '
      {
        gsub(/\{\{DATE\}\}/, ENVIRON["TODAY"])
        print
      }
    ' "$src" > "$tmp"
  else
    cp "$src" "$tmp"
  fi
  mv -n "$tmp" "$dst" 2>/dev/null || {
    # POSIX mv -n is not universal. If dest appeared, keep it and drop the temp.
    if [ -e "$dst" ]; then
      rm -f "$tmp"
      skipped_files=$((skipped_files + 1))
      echo "skipped      $label (already exists)"
      return 0
    fi
    mv "$tmp" "$dst"
  }
  if [ -f "$tmp" ]; then
    # mv -n may leave tmp if dest exists on some systems
    if [ -e "$dst" ] && [ -f "$tmp" ]; then
      rm -f "$tmp"
    fi
  fi
  if [ -f "$dst" ]; then
    created_files=$((created_files + 1))
    echo "created file $label"
  fi
}

for name in $ROOT_FILES; do
  subst=""
  if [ "$name" = "log.md" ]; then
    subst="date"
  fi
  copy_no_clobber "$TEMPLATES/$name" "$DEST/$name" "$name" "$subst"
done

# Page shape templates live under _templates/, not as live wiki pages.
if [ -d "$TEMPLATES/notes" ]; then
  for src in "$TEMPLATES/notes"/*.md; do
    [ -f "$src" ] || continue
    base=$(basename -- "$src")
    copy_no_clobber "$src" "$DEST/_templates/$base" "_templates/$base" ""
  done
fi

# A tiny gitignore for junk files only. Do not ignore .obsidian (the human may want to keep settings).
if [ ! -e "$DEST/.gitignore" ]; then
  cat > "$DEST/.gitignore" << 'EOF'
.DS_Store
Thumbs.db
*.tmp
.init-vault.tmp.*
EOF
  created_files=$((created_files + 1))
  echo "created file .gitignore"
else
  skipped_files=$((skipped_files + 1))
  echo "skipped      .gitignore (already exists)"
fi

echo
echo "Vault:    $DEST"
echo "Created:  $created_dirs dirs, $created_files files"
echo "Skipped:  $skipped_files existing files (left unchanged)"
echo
echo "Next: fill in the Domain section of SCHEMA.md, then (optionally) open this folder in Obsidian and make it a git repo. See the recipe README."
