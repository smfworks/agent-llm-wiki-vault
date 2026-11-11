# Agent LLM Wiki Vault

A folder of linked markdown pages that a local AI agent reads before it acts and writes to after it learns. This repository is a practical recipe for building and keeping that folder healthy — for people running [Hermes Agent](https://hermes-agent.nousresearch.com/docs/), [OpenClaw](https://docs.openclaw.ai/), or a similar local agent.

It is published by [SMF Works](https://github.com/smfworks/agent-llm-wiki-vault).

## Why this matters

A strong model with no memory is a brilliant stranger who meets you fresh every morning. The same model, sitting on a well-kept wiki of what it has learned about its job, starts to feel like a colleague. The knowledge is compiled once and then kept current, instead of being pieced together from scratch on every question.

That idea is older than any chatbot. This recipe follows [The Vault Is the Agent: Why Autonomous AI Needs an LLM Wiki as Its Second Brain](https://x.com/MichaelGannotti/status/2120592530450292935), an X Article from SMF Works (11 November 2026), and [Andrej Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f) (4 April 2026). Karpathy's line is the shortest version: "Obsidian is the IDE; the LLM is the programmer; the wiki is the codebase." Humans often abandon wikis because the maintenance grows faster than the value. Here the agent does the filing, and you decide what is true.

You do not need Obsidian. A vault is just a folder. Obsidian is a good window into it.

## What's in this repository

| Path | What it is |
|------|------------|
| [AGENT-SETUP.md](AGENT-SETUP.md) | Hand this to your agent: "Read AGENT-SETUP.md and walk me through it." |
| [templates/](templates/) | Starter `SCHEMA.md`, `AGENTS.md`, `index.md`, `log.md`, page shapes, and a lint checklist |
| [prompts/](prompts/) | Reusable prompts for ingest, nightly research, retrieval before answering, and weekly lint |
| [scripts/init-vault.sh](scripts/init-vault.sh) | Creates the folder layout without overwriting anything |
| [scripts/lint-vault.py](scripts/lint-vault.py) | Reports broken wikilinks, missing frontmatter, and stale dates — it never edits files |
| [CREDITS.md](CREDITS.md) | Attribution for the article, Karpathy's gist, and the Hermes llm-wiki skill (MIT, © 2025 Nous Research) |
| [LICENSE](LICENSE) | MIT |

This repository is the recipe, not your private notebook. Keep your actual vault in its own folder, and do not publish it with secrets in it.

## Prerequisites

- A computer you control, with a folder you are willing to treat as the vault.
- macOS or Linux with a terminal. On Windows, use WSL or Git Bash for `scripts/init-vault.sh`, or create the folders by hand from the layout below.
- Python 3.9 or later for `scripts/lint-vault.py` (standard library only). On Windows run it as `py scripts\lint-vault.py <vault>`.
- A local agent you already use, or plan to use: Hermes Agent, OpenClaw, or another agent that can read and write markdown files.
- Optional: [Obsidian](https://obsidian.md/help/cli) 1.12 or later if you want the official CLI (backlinks, orphans, unresolved links, daily notes). The [1.12 public release](https://obsidian.md/changelog/2026-02-27-desktop-v1.12.4/) shipped the CLI; official help says you need the **1.12.7 or later installer**, then Settings → General → enable Command line interface.
- Optional: `git`, so the vault has version history. Karpathy's gist notes that a wiki is "just a git repo of markdown files."
- Optional, servers only: [Obsidian Headless](https://obsidian.md/help/headless) if you want to sync a vault without the desktop app. That is a Sync client, not a substitute for the desktop CLI.

You do not need a database, an embedding pipeline, or a cloud account to start.

## The vault layout

The core (`SCHEMA.md`, `index.md`, `log.md`, `raw/`, entity and concept pages) comes from Karpathy's gist and the [Hermes llm-wiki skill](https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/research/research-llm-wiki). The `research/`, `decisions/`, `dreams/`, `daily/`, and `_archive/` folders are the additions from the article for an agent that works over days and weeks. `comparisons/` and `queries/` are included because the Hermes skill uses them for filed analyses and hard-won answers.

```
vault/
  SCHEMA.md         rules the agent reads first (fill in the Domain section)
  AGENTS.md         standing instructions for any agent working here
  index.md          one line per page
  log.md            append-only timeline: ## [YYYY-MM-DD] ingest | Title
  lint-checklist.md weekly health-check list
  raw/              sources, never edited
    articles/
    papers/
    transcripts/
    assets/
  entities/         people, products, organizations
  concepts/         ideas, patterns, policies
  comparisons/      side-by-side analyses
  queries/          filed answers that would be painful to re-derive
  research/         nightly research notes (historical)
  decisions/        dated decisions (historical)
  dreams/           dream or reflection diary entries (historical)
  daily/            the day's running notes (historical)
  _archive/         superseded pages, kept forever
  _templates/       page shapes to copy, not live wiki pages
```

OpenClaw's bundled [memory-wiki plugin](https://docs.openclaw.ai/plugins/memory-wiki) can compile a wiki of its own, with a slightly different default tree (for example `sources/`, `syntheses/`, `reports/`). That compiled wiki can sit beside this layout, or you can point it at a folder and follow the official plugin docs. Do not assume `openclaw wiki init` creates the tree above — it creates OpenClaw's starter layout, and it only creates missing files (it does not overwrite). **Recommended: keep OpenClaw's compiled wiki in a separate folder.** See [Connect it to OpenClaw](#5-connect-it-to-openclaw).

## Conventions

Copy `templates/SCHEMA.md` and keep it honest. The important habits:

- **Frontmatter on every wiki page.** Required fields in this recipe: `title`, `type`, `status`, `created`, `updated`. Also set `confidence`, `sources`, and (for current pages) `review_after`. Dates use `YYYY-MM-DD`.
- **Status.** `current` means act on this. `superseded` means it was true once; `superseded_by` points at the replacement. `historical` is a record of something that happened, so it never goes stale. Decisions, dreams, daily notes, dated research notes, and `log.md` are historical.
- **Links.** Use `[[wikilinks]]`. New or updated pages should have at least two outbound links.
- **Sources.** Leave the captured text in `raw/` with `source_url`, `ingested`, and a `sha256` of the body after the frontmatter. Wiki pages cite those files. Never edit `raw/` to "fix" a fact; fix the wiki page instead.
- **Disagreement.** If sources disagree, write both positions with dates, set `contested: true`, and ask a human. Do not overwrite quietly.
- **Names.** Lowercase, hyphenated filenames, such as `sleep-time-compute.md`.
- **Index and log.** Every new page gets a one-line entry in `index.md`. Every action appends to `log.md`.

Starter shapes for an entity, a concept, a raw source, a daily note, a research note, a decision, a dream entry, and a superseded page are in `templates/notes/`.

## Step-by-step setup

If you would rather have your agent do this with you, open [AGENT-SETUP.md](AGENT-SETUP.md) and say: "Read AGENT-SETUP.md and walk me through it."

### 1. Create the vault

From a clone of this repository:

```sh
git clone https://github.com/smfworks/agent-llm-wiki-vault.git
cd agent-llm-wiki-vault
scripts/init-vault.sh ~/Documents/agent-vault
```

The script creates folders and copies starter files. If a file already exists, it leaves it alone and says so. Open `SCHEMA.md` and replace the Domain placeholder with a short, specific description of the job this vault is for.

### 2. Optionally open it in Obsidian

In Obsidian, open the vault folder as a vault. Enable wikilinks if they are not already on. You may set the attachment folder to `raw/assets/`.

If you want the official CLI (optional, but useful for orphans, unresolved links, backlinks, and `daily:append`):

1. Install Obsidian with the 1.12.7 or later installer, as described in [Obsidian CLI](https://obsidian.md/help/cli).
2. Settings → General → enable Command line interface, and finish the registration prompt.
3. Leave Obsidian running. The CLI talks to the running app; if the app is closed, the first command launches it.

The `vault=` parameter has to come first when you target a named vault. Examples from official help, using a vault name you choose:

```sh
obsidian vault="Agent Vault" search query="sleep-time compute"
obsidian vault="Agent Vault" backlinks file=sleep-time-compute
obsidian vault="Agent Vault" orphans
obsidian vault="Agent Vault" unresolved verbose
obsidian vault="Agent Vault" daily:append content="- Decision: ..."
```

On a machine with no desktop, use [Obsidian Headless](https://obsidian.md/help/headless) for Sync, not the desktop CLI. Official help is clear that Headless is a standalone Sync/Publish client; the desktop CLI controls the running app. Follow that page for install and login. Do not put account passwords in this vault or in a prompt you save here.

### 3. Optionally make it a git repo

```sh
cd ~/Documents/agent-vault
git init
git add .
git commit -m "Initialize agent wiki vault"
```

Commit after meaningful ingests and after a weekly lint you have reviewed. Do not commit secrets. If the vault is private, keep the remote private too.

### 4. Connect it to Hermes Agent

Official skill docs: [llm-wiki](https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/research/research-llm-wiki). Official memory, cron, and delegation docs are linked under [Resources](#resources).

1. Install the optional skill:

   ```sh
   hermes skills install official/research/llm-wiki
   ```

2. Point Hermes at the vault. The skill reads `WIKI_PATH` (for example from `${HERMES_HOME:-~/.hermes}/.env`). If that variable is unset, the skill defaults to `~/wiki`. To use the folder you just created, set `WIKI_PATH` to that absolute path and open a new session so the change is picked up. If you also use the bundled [Obsidian skill](https://hermes-agent.nousresearch.com/docs/user-guide/skills/bundled/note-taking/note-taking-obsidian), official llm-wiki docs say to set `OBSIDIAN_VAULT_PATH` to the same directory.

3. Hermes already has a small built-in memory: `MEMORY.md` (up to 2,200 characters) and `USER.md` (1,375 characters) under `~/.hermes/memories/`, injected as a frozen snapshot at the start of a session. That is not a substitute for the vault. Do not point two Hermes processes at the same Hermes home; official [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory) docs warn that two writers will compound each other's entries. Give a second agent its own profile (`hermes profile list` will show what exists). Shared knowledge belongs in this vault.

4. For nightly research, official [Scheduled Tasks (Cron)](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron) docs describe `hermes cron create`. Schedule and prompt are positional; `--skill`, `--workdir`, `--continuity`, and `--name` are documented. `--workdir` must be an absolute path to a directory that already exists. Official cron docs confirm that `--workdir` injects that folder's `AGENTS.md` into the job's system prompt.

   Cron jobs run inside the Hermes gateway. Make sure it is running (`hermes gateway install` for a user service, or `hermes gateway` in the foreground), and check with `hermes cron status`. Each run is a fresh session, so the prompt must contain everything the job needs.

   Copy only the prompt **below the `---` line** of [prompts/nightly-research.md](prompts/nightly-research.md), fill in `[JOB]` and `[TOPICS]`, and save it as a local file (not in a public gist if it describes a private job). For the first run, create the job with `--paused`, inspect it with `hermes cron list`, run it once with `hermes cron run nightly-research`, then `hermes cron resume nightly-research`:

   ```sh
   hermes cron create "0 1 * * *" "$(cat nightly-research.txt)" \
     --skill llm-wiki --workdir /path/to/your/vault \
     --continuity --name nightly-research --paused
   ```

5. Before answering questions in the vault's domain, use [prompts/retrieval-before-answer.md](prompts/retrieval-before-answer.md). Official [Subagent Delegation](https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation) docs warn that subagents start from a blank conversation ("Subagents Know Nothing") and that leaf subagents cannot write shared persistent memory. Put the question, the vault path, and the rules in the call.

### 5. Connect it to OpenClaw

Official plugin docs: [Memory wiki](https://docs.openclaw.ai/plugins/memory-wiki). Official CLI: [wiki](https://docs.openclaw.ai/cli/wiki). Config file, unless you have set `OPENCLAW_CONFIG_PATH`: [`~/.openclaw/openclaw.json`](https://docs.openclaw.ai/gateway/configuration). Default workspace: `~/.openclaw/workspace`. Default state directory: `~/.openclaw` (or `OPENCLAW_STATE_DIR`).

OpenClaw's built-in memory (`MEMORY.md`, dated files under `memory/`, `DREAMS.md`) is separate from the compiled wiki. Official memory docs put it plainly: "The model only remembers what gets saved to disk; there is no hidden state." Dreaming still belongs to the active memory plugin. `memory-wiki` sits beside it.

1. Enable the bundled plugin, then make sure the Gateway is running. The [CLI: wiki](https://docs.openclaw.ai/cli/wiki) page shows:

   ```sh
   openclaw plugins enable memory-wiki
   openclaw gateway restart
   ```

   The plugin page also notes that enablement applies to a running Gateway automatically, and that you should start the Gateway if it is offline. If you are unsure which applies, follow the CLI page and then run `openclaw wiki status`.

2. Back up `~/.openclaw/openclaw.json` (or the path printed by `openclaw config file`) before you edit it. Official docs prefer `openclaw config set <key> <value> --dry-run` over hand edits (writes route through a running Gateway), and a symlinked `openclaw.json` is unsupported for writes. See [Configuration](https://docs.openclaw.ai/gateway/configuration) and [Config](https://docs.openclaw.ai/cli/config). Put memory-wiki settings under `plugins.entries.memory-wiki.config` as the [plugin docs](https://docs.openclaw.ai/plugins/memory-wiki) describe. A common starting point from those docs is `vaultMode: "isolated"` (its own vault, no dependency on the memory plugin), `vault.scope: "global"` (one shared wiki), and, if you use Obsidian, `vault.renderMode: "obsidian"`. The official default global path is `~/.openclaw/wiki/main`.

   **Recommended: keep them separate.** Leave OpenClaw's compiled wiki at its default path (`~/.openclaw/wiki/main`) and give the agent this recipe vault as an ordinary folder. Pointing `vault.path` at this recipe vault is not recommended: `openclaw wiki compile` (which also runs after each ingest by default) adds a generated block to your `index.md`, creates `index.md` files inside `entities/` and `concepts/`, and writes pages with OpenClaw's own frontmatter (`pageType`, `id`, `status: active`), which `scripts/lint-vault.py` will report as errors. `openclaw wiki init` itself only creates missing files and does not overwrite. If you still want one tree, point `vault.path` at a **subfolder** such as `<vault>/openclaw/` and treat it as OpenClaw-owned.

3. Official CLI commands, after the plugin is enabled:

   ```sh
   openclaw wiki status
   openclaw wiki doctor
   openclaw wiki lint
   openclaw wiki search "your topic"
   ```

   If Obsidian-friendly mode is on and the official CLI is enabled, `openclaw wiki obsidian` provides `status`, `search`, `open`, `command`, and `daily`. Official docs reject `obsidian.useOfficialCli: true` when `vault.scope` is `agent`, because `obsidian.vaultName` is one global setting.

4. For a nightly research job, use [Automations](https://docs.openclaw.ai/automation/cron-jobs) (the article notes that `openclaw cron` still works as an alias). Prefer an official documented command over anything invented here. Official [Dreaming](https://docs.openclaw.ai/concepts/dreaming) defaults to `0 3 * * *`. Schedule research at a different hour, and have the job write files — cron sessions are not ingested into dreaming.

5. If you use dreaming, file a useful diary entry as `dreams/YYYY-MM-DD.md` with `status: historical`, and link it to the pages it touched. Official docs say the diary is for human reading, not a promotion source. In bridge mode, `indexDreamReports` can index dream reports next to daily notes; see the plugin docs rather than guessing the surrounding keys.

6. For retrieval, see [Active memory](https://docs.openclaw.ai/concepts/active-memory) and [Sub-agents](https://docs.openclaw.ai/tools/subagents). With memory-wiki enabled, `wiki_search` and `wiki_get` can search by claim and evidence. Use [prompts/retrieval-before-answer.md](prompts/retrieval-before-answer.md) as the brief.

### 6. Any other local agent

Give the agent this repository and the vault path. Ask it to read `SCHEMA.md`, `AGENTS.md`, and `AGENT-SETUP.md`. It should use ordinary file tools: read, search, and write markdown. The loops and conventions in this README still apply. Do not invent platform flags.

## Daily, nightly, and weekly loops

These are the habits that turn a folder into a second brain. The 3:00 AM dreaming slot is OpenClaw's documented default; the other times are suggestions from the article.

**During the day.** Put decisions, approvals, corrections from you, and anything with a deadline into today's daily note as they happen, with a link to the page they affect. If the Obsidian CLI is available, `daily:append` can add a line without opening the file by hand. Official OpenClaw memory docs also describe a silent flush before a long conversation is compacted, and they suggest recording when it is safe to act on a note (an approval, an expiry, a handoff), not just the fact itself.

**At night, research.** The agent researches *its own job*, reads the related wiki pages first, and answers three questions about each new item: what changed compared with what we already know, whether it contradicts a current page, and what it means for the job this week. It saves sources to `raw/`, writes `research/YYYY-MM-DD-topic.md`, updates the pages it touches (at least two wikilinks each), and logs the change. Use [prompts/nightly-research.md](prompts/nightly-research.md). Karpathy notes that a single source might touch 10 to 15 wiki pages. That is the compounding.

**At night, dreams (OpenClaw, and a lighter version on Hermes).** OpenClaw dreaming runs light, then REM, then deep; only deep writes `MEMORY.md`. File the diary as historical. Hermes does not call this dreaming, but official memory docs describe a background self-improvement review and `/journey`. If you want a dream journal in the vault, schedule a short reflection that writes `dreams/YYYY-MM-DD.md` and does not invent facts.

**In the morning.** A fresh session reads the updated vault. Retrieval scouts start from current pages.

**Every week, lint.** Clear stale facts from the current layer; keep every piece of history. Use [prompts/weekly-lint.md](prompts/weekly-lint.md) and `scripts/lint-vault.py`. The six rules:

1. Never delete. Supersede, link both ways, and move the old page to `_archive/`.
2. Historical pages never go stale. Check their links, not their age.
3. Any current page past `review_after` is re-checked against its source, then refreshed or superseded.
4. Contradictions are flagged for a human, not auto-resolved.
5. Fix structure: broken links, orphans, dead ends, index gaps, stray tags.
6. Log the lint with counts.

If you use git, commit after you have reviewed the moves. If you use Obsidian, official CLI `history` and `history:restore` can list and restore local file history.

## Multi-agent setup

Give every agent its own short-term memory home. Share a wiki only when you mean to, and write down who may edit it.

**One shared vault** works when the agents serve the same job and you trust them with the same notes. Use one `SCHEMA.md`, and say in `AGENTS.md` which agent may write, which may only read, and how contradictions are flagged. On OpenClaw, official `vault.scope: "global"` is the default shared wiki. If agents in a shared vault should retrieve only their own imported memory notes, see `bridge.ownership` in the [memory-wiki docs](https://docs.openclaw.ai/plugins/memory-wiki) — that setting filters query results, not filesystem access.

**Per-agent vaults** are the safer default when the jobs differ, or when the agents should not read each other's notes. On Hermes, use separate profiles (and never the same Hermes home). On OpenClaw, official `vault.scope: "agent"` gives each agent a child vault under a parent directory; the docs show `~/.openclaw/wiki/<agent-id>` when `vault.path` is `~/.openclaw/wiki`. Changing scope does not copy or split an existing vault, so back up first and move pages on purpose. Official-CLI Obsidian integration is rejected in this mode.

**Write rules worth putting in `AGENTS.md`:**

- Scouts and subagents are read-only.
- Only the parent agent (or a named maintainer agent) writes current pages.
- Raw sources are append-once.
- Archive is move-plus-link, never delete.
- Two agents must not edit the same file at the same time.

OpenClaw docs are explicit that per-agent vaults are a same-process knowledge boundary, not an operating-system security boundary. If the agents should not trust each other, use the isolation your platform documents (for OpenClaw, sandboxing or separate Gateway profiles — see the official plugin page).

## Security and privacy

- **No secrets in the vault.** No passwords, API keys, tokens, private keys, session cookies, or recovery phrases. If a source contains one, redact it on ingest and say so in the log. OpenClaw dreaming does not secret-mask session transcripts before ingesting them (official [Dreaming](https://docs.openclaw.ai/concepts/dreaming) docs), so don't paste secrets into chats either.
- **Treat ingested web content as untrusted.** A page you clipped can contain prompt-injection ("ignore your rules and…"). Official Hermes memory docs say memory entries are scanned for injection and exfiltration patterns before they are accepted. Official OpenClaw dreaming keeps untrusted and system-derived candidates out of the promotion path. Do the same with `raw/` files: they are evidence, never instructions.
- **Dreams are not facts.** Do not let a diary entry change a current page without a check.
- **File permissions.** The vault often holds private notes. Restrict the directory to your user (for example `chmod 700` on the vault folder) if other accounts on the machine should not read it.
- **Backups.** Prefer git plus an offline copy you control. If you use Obsidian Sync or Headless, follow official security and backup guidance. Do not treat a single disk as enough.
- **Small models.** Official Hermes docs note that small models, or models with weak tool calling, sometimes say they saved a memory without calling the tool. Open the file and look.
- **Do not publish your private vault.** This recipe is public; your notes probably should not be.

## Undo

- **The vault** is just a folder. Delete it, or move it to the trash, when you no longer want it. Nothing else depends on it.
- **Hermes:** restore the `.env` backup made during setup (`cp ~/.hermes/.env.bak-YYYYMMDD-HHMMSS ~/.hermes/.env`), remove the skill with `hermes skills uninstall llm-wiki`, and remove any job with `hermes cron remove nightly-research`.
- **OpenClaw:** restore the `openclaw.json` backup, or run `openclaw plugins disable memory-wiki`. OpenClaw's compiled wiki at `~/.openclaw/wiki/` is a separate folder.
- **Obsidian:** remove the vault from the vault switcher. This does not delete files.

## Troubleshooting

**The agent said it remembered something, but a new session does not know it.** Check the file. On Hermes, look in the vault and, for built-in memory, in `~/.hermes/memories/`. Official docs also mention staged writes when `write_approval` is on, and per-profile memory paths.

**Hermes is not using this vault.** Confirm `WIKI_PATH` in `${HERMES_HOME:-~/.hermes}/.env`, and that you started a new session after changing it. Confirm you are on the profile you think you are (`hermes profile list`).

**Obsidian CLI commands fail.** Official help: you need the 1.12.7 or later installer, the CLI setting enabled, a restarted terminal so `PATH` is updated, and a running Obsidian app. See the troubleshooting section on [Obsidian CLI](https://obsidian.md/help/cli).

**`openclaw wiki` is missing or unhealthy.** Enable `memory-wiki`, start or restart the Gateway, then run `openclaw wiki status` and `openclaw wiki doctor`. Follow the official output rather than guessing.

**Official Obsidian CLI is rejected on OpenClaw.** You are probably on `vault.scope: "agent"`. That combination is rejected on purpose. Use wiki tools, or keep an Obsidian-operated wiki in global scope.

**Nightly research ran, but dreaming did not pick it up.** Official OpenClaw dreaming excludes cron, heartbeat, and subagent sessions from transcript ingestion. Write findings to files.

**The vault feels stale, or the agent acted on an old price or version.** Run a weekly lint. Check `review_after` on current pages. Do not delete the old page; supersede it so you still know why things changed.

**Two agents are stepping on each other.** On Hermes, check that they do not share a home directory. On OpenClaw, check `vault.scope` and workspace paths. Tighten write rules in `AGENTS.md`.

## Resources

Links below were checked and loaded on 11 November 2026. Prefer these official pages over stale command lists in any article, including this one.

### The article and the pattern

- [The Vault Is the Agent: Why Autonomous AI Needs an LLM Wiki as Its Second Brain](https://x.com/MichaelGannotti/status/2120592530450292935) — X Article, SMF Works, 11 November 2026
- [Andrej Karpathy, LLM Wiki (GitHub gist)](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f)
- [Vannevar Bush, As We May Think (The Atlantic, July 1945, archived)](https://web.archive.org/web/20120822124246/http://www.theatlantic.com/magazine/archive/1945/07/as-we-may-think/303881/)
- [Niklas Luhmann Archive, Bielefeld University](https://www.uni-bielefeld.de/fakultaeten/soziologie/forschung/luhmann-archiv/)
- [Wired, 25 March 1995: First Wiki Makes Fast Work of Collaboration](https://www.wired.com/2010/03/0325wikiwikiweb-first-wiki/)
- [Tiago Forte, Building a Second Brain: The Definitive Introductory Guide](https://fortelabs.com/blog/basboverview/)
- [Tiago Forte, Building a Second Brain Is Out in the World](https://fortelabs.com/blog/final-book-update-my-book-is-out-in-the-world/)

### Papers and memory research

- [Park et al., Generative Agents (arXiv:2304.03442)](https://arxiv.org/abs/2304.03442)
- [Packer et al., MemGPT (arXiv:2310.08560)](https://arxiv.org/abs/2310.08560)
- [Letta, MemGPT Is Now Part of Letta](https://www.letta.com/blog/memgpt-and-letta/)
- [Lin et al., Sleep-time Compute (arXiv:2504.13171)](https://arxiv.org/abs/2504.13171)

### Hermes Agent

- [Hermes Agent docs](https://hermes-agent.nousresearch.com/docs/)
- [Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory)
- [Skills System](https://hermes-agent.nousresearch.com/docs/user-guide/features/skills)
- [llm-wiki skill](https://hermes-agent.nousresearch.com/docs/user-guide/skills/optional/research/research-llm-wiki)
- [Obsidian skill](https://hermes-agent.nousresearch.com/docs/user-guide/skills/bundled/note-taking/note-taking-obsidian)
- [Scheduled Tasks (Cron)](https://hermes-agent.nousresearch.com/docs/user-guide/features/cron)
- [Subagent Delegation](https://hermes-agent.nousresearch.com/docs/user-guide/features/delegation)

### OpenClaw

- [OpenClaw docs](https://docs.openclaw.ai/)
- [Memory overview](https://docs.openclaw.ai/concepts/memory)
- [Dreaming](https://docs.openclaw.ai/concepts/dreaming)
- [Memory wiki plugin](https://docs.openclaw.ai/plugins/memory-wiki)
- [CLI: wiki](https://docs.openclaw.ai/cli/wiki)
- [Active memory](https://docs.openclaw.ai/concepts/active-memory)
- [Automations](https://docs.openclaw.ai/automation/cron-jobs)
- [Sub-agents](https://docs.openclaw.ai/tools/subagents)
- [Configuration](https://docs.openclaw.ai/gateway/configuration) (default file: `~/.openclaw/openclaw.json`)

### Obsidian

- [Obsidian CLI](https://obsidian.md/help/cli) (the older `help.obsidian.md/cli` URL redirects here)
- [Obsidian 1.12 Desktop (Public) changelog](https://obsidian.md/changelog/2026-02-27-desktop-v1.12.4/)
- [Obsidian Headless](https://obsidian.md/help/headless)
- [Headless Sync](https://obsidian.md/help/sync/headless)

### SMF Works posts cited in the article

- [Aiona Edge, OpenClaw v2026.4.12: When Your AI Starts Dreaming — And Remembering](https://www.smfclearinghouse.com/blog/openclaw-v2026-4-12-dreaming-alive/)
- [Liam Hermes, Delegation Transport](https://www.smfclearinghouse.com/blog/2026-07-15-delegation-transport-subprocess-gateway-vault/)

This recipe does not require an MCP server. Official Obsidian does not ship a first-party MCP server. If you later want a tool layer on top of a markdown folder, start from official or clearly labeled community projects and review them yourself.

## Credits

See [CREDITS.md](CREDITS.md) for attribution of the X Article, Karpathy's LLM Wiki gist, and the Hermes Agent llm-wiki skill (Nous Research, MIT, © 2025), including that skill's license notice.

## License

[MIT](LICENSE). Copyright (c) 2026 SMF Works.
