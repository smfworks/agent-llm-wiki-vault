# Reusable prompts

Copy the body of a prompt into a chat, a skill, or a scheduled job. Fill in the placeholders (`[VAULT_PATH]`, `[JOB]`, `[TOPICS]`, `[QUESTION]`) first.

| File | When to use it |
|------|----------------|
| `ingest.md` | The human gives you a URL, file, or pasted source to add. |
| `nightly-research.md` | A scheduled job that researches the agent's actual job, reasons against existing pages, and files the result. |
| `retrieval-before-answer.md` | Before answering a question in the vault's domain. |
| `weekly-lint.md` | A weekly health check that archives superseded pages instead of deleting them. |

These prompts assume the vault follows `templates/SCHEMA.md`. They do not grant an agent permission to run commands or overwrite files. For a first-time setup, use `../AGENT-SETUP.md`.
