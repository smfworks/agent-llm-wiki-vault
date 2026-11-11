# Scripts

Small, local helpers. They do not talk to the network and they do not delete vault files.

## `init-vault.sh`

Creates the folder layout and copies starter files from `templates/` into a destination directory. Existing files are left unchanged, so it is safe to re-run.

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
- wiki pages missing YAML frontmatter or missing `title`, `type`, `status`, `created`, or `updated`
- `current` pages whose `review_after` date is in the past
- optionally, `current` pages whose `updated` date is older than `--stale-days`

Historical and superseded pages are not flagged as stale by date. `SCHEMA.md`, `index.md`, `log.md`, `AGENTS.md`, files under `raw/`, and `_templates/` are not treated as wiki pages for frontmatter checks.

Requires Python 3, standard library only.
