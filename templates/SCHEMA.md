# Wiki Schema

Read this file first, every session, before you ingest, answer, or lint.

## Domain

_Replace this line with a short description of what this vault covers. Be specific: a job, a research area, or a project — not "everything."_

## How the vault is organized

Three layers, from [Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) and the [Hermes llm-wiki skill](https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/research/research-llm-wiki):

1. **Raw sources** (`raw/`) — evidence the agent reads and never edits.
2. **Wiki pages** (`entities/`, `concepts/`, and the other page folders) — the agent owns these and keeps them current.
3. **Schema** (this file) — the rules.

`index.md` is the catalog. `log.md` is the append-only timeline. The folders `research/`, `decisions/`, `dreams/`, `daily/`, and `_archive/` are for an agent that works over time, as described in [The Vault Is the Agent](https://x.com/MichaelGannotti/status/2120592530450292935).

## Conventions

- File names: lowercase, hyphens, no spaces (for example, `sleep-time-compute.md`).
- Every wiki page starts with YAML frontmatter (see below).
- Use `[[wikilinks]]` between pages. New or updated pages should have at least two outbound wikilinks.
- When you update a page, bump `updated` to today.
- Add every new page to `index.md` under the right section, and append a line to `log.md`.
- On pages that synthesize three or more sources, you may add a short provenance marker such as `^[raw/articles/source-file.md]` at the end of a paragraph whose claims come from that source.
- Never modify files in `raw/`. Corrections belong on wiki pages.
- Never delete a page to "clean up." Supersede it and move it to `_archive/`.

## Frontmatter

Required on wiki pages (`entities/`, `concepts/`, `comparisons/`, `queries/`, `research/`, `decisions/`, `dreams/`, `daily/`):

```yaml
---
title: Example page title
type: entity          # entity | concept | comparison | query | research | decision | dream | daily | source
status: current       # current | superseded | historical
created: YYYY-MM-DD
updated: YYYY-MM-DD
review_after: YYYY-MM-DD
supersedes:
superseded_by:
confidence: medium    # high | medium | low
contested: false
contradictions: []
tags: []
sources: []
---
```

Field notes:

- `created`, `updated`, `confidence`, and `contested` follow the [Hermes llm-wiki](https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/research/research-llm-wiki) schema.
- `status`, `supersedes`, `superseded_by`, and `review_after` are the additions from the article, so a lint pass can tell a stale fact from a piece of history.
- **current** — act on this.
- **superseded** — this was true once; `superseded_by` points at what replaced it.
- **historical** — a record of something that happened. It does not go stale. Decisions, dreams, daily notes, dated research notes, and `log.md` are historical.

When sources disagree, note both positions with dates. Set `contested: true` and list the other page under `contradictions`. Do not silently overwrite.

## Raw source frontmatter

Files in `raw/` also get a small header so a later ingest can detect drift. Hash **only the body after the closing `---`**, as the Hermes llm-wiki skill describes:

```yaml
---
title: Example source title
type: source
source_url: https://example.com/article
ingested: YYYY-MM-DD
sha256:
---
```

## Tag taxonomy

Add tags here before you use them on a page. Start small and grow the list on purpose.

- `source`
- `decision`
- `research`
- `entity`
- `concept`

## Page thresholds

- Create a page when something appears in two or more sources, or is central to one source.
- Do not create a page for a passing mention.
- Split a page when it grows past about 200 lines.
- When a current page is fully replaced, set `status: superseded`, add `superseded_by`, move it to `_archive/` (keep the original subfolder, for example `_archive/entities/old-page.md`), link the new page back with `supersedes`, and remove the old entry from `index.md`.

## Update policy

1. Check the dates. Newer sources generally supersede older ones.
2. If the sources genuinely disagree, keep both claims with dates and sources.
3. Mark the contradiction in frontmatter and flag it for a human. Do not auto-resolve it.
4. Log the change in `log.md`.
