# Starter vault files

Copy these into a new vault with `scripts/init-vault.sh`, or by hand. The script never overwrites a file that already exists.

| File | Goes to |
|------|---------|
| `SCHEMA.md` | Vault root. Rules the agent reads first. Fill in the Domain section. |
| `AGENTS.md` | Vault root. Standing instructions for any agent working in the vault. |
| `index.md` | Vault root. One-line catalog of pages. |
| `log.md` | Vault root. Append-only timeline. The init script stamps today's date. |
| `lint-checklist.md` | Vault root. Weekly health-check list. |
| `notes/*.md` | Copied to `_templates/` in the vault, so you have page shapes to duplicate. They are not live wiki pages. |

Empty folders the init script also creates: `raw/articles`, `raw/papers`, `raw/transcripts`, `raw/assets`, `entities`, `concepts`, `comparisons`, `queries`, `research`, `decisions`, `dreams`, `daily`, `_archive`.
