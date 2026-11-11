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
      if [ "$#" -ne 1 ] || [ -n "$DEST" ]; then
        usage
      fi
      DEST="$1"
      shift
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
  SCRIPT_DIR=$(CDPATH='' cd -- "$(dirname -- "$0")" && pwd)
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

mkdir -p -- "$DEST"
DEST=$(CDPATH='' cd -- "$DEST" && pwd)
case "$DEST" in
  /|/bin|/boot|/dev|/etc|/lib|/lib64|/proc|/sbin|/sys|/usr|/usr/*|/var|/System|/System/*|/Library)
    echo "Refusing to create a vault in a system directory: $DEST" >&2
    exit 1
    ;;
esac
if [ -n "${HOME:-}" ] && [ "$DEST" = "$(CDPATH='' cd -- "$HOME" 2>/dev/null && pwd)" ]; then
  echo "Refusing to use your home directory itself as the vault. Pick a subfolder, such as ~/Documents/agent-vault." >&2
  exit 1
fi
TEMPLATES=$(CDPATH='' cd -- "$TEMPLATES" && pwd)

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
    mkdir -p -- "$path"
    created_dirs=$((created_dirs + 1))
    echo "created dir  $rel"
  fi
done

# Today's date in the local timezone.
TODAY=$(date +%Y-%m-%d 2>/dev/null || true)
if [ -z "$TODAY" ]; then
  TODAY="YYYY-MM-DD"
fi

copy_no_clobber() {
  src="$1"
  dst="$2"
  label="$3"
  subst="${4:-}"

  # -L catches dangling symlinks, which -e reports as missing.
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    skipped_files=$((skipped_files + 1))
    echo "skipped      $label (already exists)"
    return 0
  fi

  if [ ! -f "$src" ]; then
    echo "missing template: $src" >&2
    exit 1
  fi

  # set -C (noclobber) makes the shell create the file with O_EXCL: it never
  # replaces an existing file and never writes through a symlink.
  if [ -n "$subst" ]; then
    ( set -C; TODAY="$TODAY" awk '{ gsub(/\{\{DATE\}\}/, ENVIRON["TODAY"]); print }' "$src" > "$dst" ) 2>/dev/null
  else
    ( set -C; cat "$src" > "$dst" ) 2>/dev/null
  fi || {
    if [ -e "$dst" ] || [ -L "$dst" ]; then
      skipped_files=$((skipped_files + 1))
      echo "skipped      $label (already exists)"
      return 0
    fi
    echo "could not create $label" >&2
    exit 1
  }
  created_files=$((created_files + 1))
  echo "created file $label"
}

for name in $ROOT_FILES; do
  subst=""
  if [ "$name" = "log.md" ] || [ "$name" = "index.md" ]; then
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
GITIGNORE_TMP=$(mktemp)
printf '%s\n' .DS_Store Thumbs.db '*.tmp' > "$GITIGNORE_TMP"
copy_no_clobber "$GITIGNORE_TMP" "$DEST/.gitignore" ".gitignore" ""
rm -f "$GITIGNORE_TMP"

echo
echo "Vault:    $DEST"
echo "Created:  $created_dirs dirs, $created_files files"
echo "Skipped:  $skipped_files existing files (left unchanged)"
echo
echo "Next: fill in the Domain section of SCHEMA.md, then (optionally) open this folder in Obsidian and make it a git repo. See the recipe README."
