# Weekly lint checklist

Run this by hand, with your agent, or with `scripts/lint-vault.py` from the recipe repo. The script covers structure (broken wikilinks, missing frontmatter, overdue `review_after` dates). The rest is a judgment pass. **Never delete a page as part of lint.**

## Automated / structural

- [ ] Broken `[[wikilinks]]` (they point at a page that does not exist)
- [ ] Wiki pages missing required frontmatter (`title`, `type`, `status`, `created`, `updated`)
- [ ] Current pages whose `review_after` date is in the past
- [ ] Orphan pages (no incoming wikilinks) and dead ends (no outgoing wikilinks)
- [ ] Every wiki page appears in `index.md`; the index has no leftover entries for moved pages
- [ ] Tags used on pages also appear in the taxonomy in `SCHEMA.md`
- [ ] Files in `raw/` with a `sha256` still match their body (source drift)
- [ ] `log.md` is under about 500 entries; rotate it if not

## Current vs history

- [ ] Current pages past `review_after` were re-checked against their sources, then refreshed or superseded
- [ ] Superseded pages have `status: superseded`, a `superseded_by` link, a copy in `_archive/`, and a `supersedes` link from the new page
- [ ] Historical pages (decisions, dreams, daily notes, dated research, `log.md`) were checked for broken links only — not aged out

## Judgment (flag for a human, do not auto-resolve)

- [ ] Contradictions and pages with `contested: true`
- [ ] Low-confidence or single-source claims that should be corroborated or demoted
- [ ] Pages over about 200 lines that should be split
- [ ] Open questions that have been sitting too long

## Finish

- [ ] Append a `log.md` entry: `## [YYYY-MM-DD] lint | N issues found` and include counts
- [ ] If this vault is a git repo, commit the lint result after the human has reviewed any supersessions

On OpenClaw, after your own pass, you can also run `openclaw wiki lint` if the [memory-wiki plugin](https://docs.openclaw.ai/plugins/memory-wiki) is enabled. That lints OpenClaw's compiled wiki (structure, provenance, contradictions, open questions, low-confidence and stale claims). It is a complement to this checklist, not a replacement, and it uses OpenClaw's own vault layout.
