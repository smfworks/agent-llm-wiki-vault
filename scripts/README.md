# Scripts

Small, local helpers. They do not talk to the network and they do not delete vault files.

They need a POSIX shell (`sh` or bash; on Windows use WSL or Git Bash) and Python 3.9 or later (standard library only). On Windows you can run the linter as `py scripts\lint-vault.py <vault>`.

## `init-vault.sh`

Creates the folder layout and copies starter files from `templates/` into a destination directory. Existing files are left unchanged, so it is safe to re-run. It refuses to use `/`, `$HOME`, or other system directories as the destination. Files are created with noclobber (`set -C`), so a dangling or live symlink is never followed and never overwritten; the script prints `skip (exists):` for those paths. Directory symlinks already inside the destination may still be followed when creating nested folders.

`log.md` and `index.md` have `{{DATE}}` replaced with today's date in the local timezone.

```sh
scripts/init-vault.sh ~/Documents/agent-vault
# or, from another checkout:
scripts/init-vault.sh --templates /path/to/this-repo/templates /path/to/new-vault
```

What it creates: `SCHEMA.md`, `AGENTS.md`, `index.md`, `log.md`, `lint-checklist.md`, `_templates/` (page shapes), empty folders for `raw/` (articles, papers, transcripts, assets), `entities/`, `concepts/`, `comparisons/`, `queries/`, `research/`, `decisions/`, `dreams/`, `daily/`, and `_archive/`.

## `lint-vault.py`

Reports problems. It never edits, moves, or deletes files. Exit status is 0 when the vault is clean, 1 when issues were found, and 2 when the path or arguments are invalid.

```sh
scripts/lint-vault.py ~/Documents/agent-vault
scripts/lint-vault.py ~/Documents/agent-vault --stale-days 90
```

Checks:

- `[[wikilinks]]` that do not resolve to a markdown file in the vault (links inside fenced or inline code are ignored)
- Obsidian attachment embeds such as `![[diagram.png]]` and non-markdown links such as `[[report.pdf]]`, resolved against any non-`.md` file in the vault (for example under `raw/assets/`). Missing attachments are still flagged.
- wiki pages missing YAML frontmatter or missing `title`, `type`, `status`, `created`, or `updated`
- `created`, `updated`, and `review_after` values that look like dates but are not real calendar days (for example `2026-13-45` or `2026-02-30`)
- `current` pages whose `review_after` date is in the past
- optionally, `current` pages whose `updated` date is older than `--stale-days`

Historical and superseded pages are not flagged as stale by date. `SCHEMA.md`, `index.md`, `log.md`, `AGENTS.md`, files under `raw/`, and `_templates/` are not treated as wiki pages for frontmatter checks. Wikilinks inside `raw/` are also skipped, because those files are append-once and the reports cannot be fixed there. A leading UTF-8 BOM is ignored.

Symlinked `.md` files (and other symlinked attachments) are skipped and not followed, so a link that points outside the vault is not read. Directory symlinks may still be followed when the linter walks the tree; avoid pointing a vault subdirectory at a location you do not want scanned.

Requires Python 3.9 or later, standard library only.
