# Weekly lint (archive, do not delete)

Use this for a weekly health check. You may run `scripts/lint-vault.py` first for broken wikilinks, missing frontmatter, and overdue `review_after` dates, then do the judgment pass below. The six rules are from [The Vault Is the Agent](https://x.com/MichaelGannotti/status/2120592530450292935). Also see `templates/lint-checklist.md`.

If you use Hermes Agent, attach the [llm-wiki skill](https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/research/research-llm-wiki) so the skill's lint items (orphans, source drift, tag sprawl, the 90-day stale test against newer sources) are in play. If you use OpenClaw with [memory-wiki](https://docs.openclaw.ai/plugins/memory-wiki) enabled, you may also run `openclaw wiki lint` after this pass.

---

You are linting the markdown wiki vault at: [VAULT_PATH]

Read `SCHEMA.md`, `index.md`, `lint-checklist.md`, and recent `log.md` first. Then:

1. Never delete. A superseded page gets `status: superseded` and a `superseded_by` link, then moves to `_archive/` (keep the subfolder, for example `_archive/entities/old-page.md`). The new page links back with `supersedes`. Show the planned moves and get a yes before you move any file.

2. Historical pages never go stale. Decisions, dreams, daily notes, dated research notes, and `log.md` are records. Check their links, not their age.

3. Any current page past its `review_after` date gets re-checked against its source, then refreshed or superseded.

4. Contradictions get flagged for a human, not auto-resolved. Keep both claims with dates.

5. Fix the structure: broken links, orphans, dead ends, index gaps, and tags that are not in `SCHEMA.md`. Propose additions to the taxonomy instead of inventing tags on the fly.

6. Log the lint with counts. Append `## [YYYY-MM-DD] lint | N issues found` to `log.md` and summarize what you found, what you changed, and what needs a human.

If this vault is a git repository, do not commit until the human has reviewed supersessions. If Obsidian's official CLI is available and the app is running, you may use it for extra structure checks (`orphans`, `unresolved`, `backlinks`) as documented in [Obsidian CLI](https://obsidian.md/help/cli). Put `vault=` first when you target a named vault. Do not treat CLI output as a license to delete files.
