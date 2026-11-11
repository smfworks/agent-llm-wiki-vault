# Ingest a source into the vault

Use this when a human gives you a URL, a file, or pasted text to add to the wiki. Adapt the placeholders. Do not edit files in `raw/` after they have been saved, except to fix a capture error with the human's approval.

---

You are maintaining the markdown wiki vault at: [VAULT_PATH]

1. Orient first. Read `SCHEMA.md`, `index.md`, and the last 30 lines of `log.md`. Search for entities and concepts this source is likely to touch so you do not create duplicates.

2. Capture the source into `raw/` (articles, papers, or transcripts). Use a descriptive, lowercase, hyphenated filename. Add raw frontmatter: `title`, `type: source`, `source_url` if any, `ingested` (today's date), and `sha256` of the body after the closing `---`. If this URL was ingested before, recompute the hash: skip if it matches; if it drifted, flag that and ask before updating the raw file.

3. Discuss key takeaways with the human, unless this is an unattended cron run, in which case go on.

4. For each entity or concept that meets the page thresholds in `SCHEMA.md` (appears in two or more sources, or is central to this one), create or update the wiki page. Bump `updated`. Follow the update policy: if the source contradicts a current page, note both positions with dates, set `contested: true`, and do not overwrite. Give each new or updated page at least two `[[wikilinks]]`. Set `confidence` honestly (`high` only when multiple sources agree).

5. A single source may touch many pages. If you are about to change more than about ten existing pages, stop and confirm the scope with the human first.

6. Update `index.md` (add new pages, bump the date and count) and append one `log.md` entry: `## [YYYY-MM-DD] ingest | Source Title`. List every file you created or updated.

7. Report the files you changed. Do not store secrets from the source in the vault; redact them or skip that passage and say so.
