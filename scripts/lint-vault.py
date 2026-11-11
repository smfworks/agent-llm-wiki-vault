#!/usr/bin/env python3
"""Lint a markdown wiki vault without changing any files.

Checks:
  - broken [[wikilinks]]
  - missing required frontmatter on wiki pages
  - current pages whose review_after date is in the past
  - optional: current pages whose updated date is older than --stale-days

Never deletes, moves, or edits vault files. Exit 0 if no issues, 1 if issues
were found, 2 if the arguments are invalid or the vault cannot be read.
"""

from __future__ import annotations

import argparse
import datetime as dt
import re
import sys
from pathlib import Path

WIKI_DIR_TYPES = {
    "entities": "entity",
    "concepts": "concept",
    "comparisons": "comparison",
    "queries": "query",
    "research": "research",
    "decisions": "decision",
    "dreams": "dream",
    "daily": "daily",
}

# Folders whose pages are historical by default if status is missing.
HISTORICAL_DIRS = {"research", "decisions", "dreams", "daily"}

# Root files and folders that are not "wiki pages" for frontmatter checks.
SKIP_FRONTMATTER_TOP = {
    "schema.md",
    "agents.md",
    "index.md",
    "log.md",
    "lint-checklist.md",
    "readme.md",
}

SKIP_DIRS = {".git", ".obsidian", ".trash", "__pycache__", "_templates"}

REQUIRED_FIELDS = ("title", "type", "status", "created", "updated")
VALID_STATUS = {"current", "superseded", "historical"}
DATE_RE = re.compile(r"^\d{4}-\d{2}-\d{2}$")
WIKILINK_RE = re.compile(r"\[\[([^\]]+)\]\]")
FENCE_RE = re.compile(r"^ {0,3}(`{3,}|~{3,})")


def parse_args(argv: list[str]) -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Lint a vault for broken wikilinks, missing frontmatter, and stale dates. Does not modify files."
    )
    p.add_argument("vault", help="Path to the vault directory")
    p.add_argument(
        "--stale-days",
        type=int,
        default=None,
        metavar="N",
        help="Also flag current pages whose updated date is more than N days ago (historical and superseded pages are skipped)",
    )
    p.add_argument(
        "--today",
        default=None,
        help="YYYY-MM-DD to treat as today (for tests). Default: the system date.",
    )
    return p.parse_args(argv)


def parse_today(value: str | None) -> dt.date:
    if value:
        try:
            return dt.date.fromisoformat(value)
        except ValueError:
            raise SystemExit("error: --today must be YYYY-MM-DD")
    return dt.date.today()


def parse_date(value: str) -> dt.date | None:
    """Return a date for a real YYYY-MM-DD value, or None (also for 2026-13-45 or 2026-02-30)."""
    if not DATE_RE.match(value):
        return None
    try:
        return dt.date.fromisoformat(value)
    except ValueError:
        return None


def split_frontmatter(text: str) -> tuple[dict[str, str] | None, str]:
    """Return (fields, body). fields is None when no opening YAML frontmatter is present."""
    text = text.removeprefix("\ufeff")
    if not text.startswith("---"):
        return None, text
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None, text
    end = None
    for i, line in enumerate(lines[1:], start=1):
        if line.strip() == "---":
            end = i
            break
    if end is None:
        return None, text
    fields: dict[str, str] = {}
    for raw in lines[1:end]:
        if not raw.strip() or raw.strip().startswith("#"):
            continue
        if ":" not in raw:
            continue
        key, val = raw.split(":", 1)
        key = key.strip()
        val = val.strip().strip("'\"")
        # Keep only simple scalars; lists and empty values are stored as the raw string.
        if key:
            fields[key] = val
    body = "\n".join(lines[end + 1 :])
    return fields, body


def strip_code(text: str) -> str:
    """Remove fenced and inline code so links inside examples are not linted."""
    out = []
    fence = None
    for line in text.splitlines():
        m = FENCE_RE.match(line)
        if m:
            marker = m.group(1)[0]
            count = len(m.group(1))
            token = marker * count
            if fence is None:
                fence = token
            elif line.strip().startswith(fence):
                fence = None
            continue
        if fence is None:
            out.append(line)
    cleaned = "\n".join(out)
    cleaned = re.sub(r"`[^`\n]*`", "", cleaned)
    return cleaned


def iter_markdown(vault: Path) -> list[Path]:
    files = []
    for path in sorted(vault.rglob("*.md")):
        if path.is_symlink():
            continue
        rel_parts = path.relative_to(vault).parts
        if any(part in SKIP_DIRS or part.startswith(".") for part in rel_parts[:-1]):
            continue
        files.append(path)
    return files


def page_targets(vault: Path, files: list[Path]) -> dict[str, Path]:
    """Map possible wikilink targets (stem, name, relative path, lowercase variants) to files."""
    mapping: dict[str, Path] = {}
    for path in files:
        rel = path.relative_to(vault).as_posix()
        stem = path.stem
        name = path.name
        keys = {
            rel,
            rel[:-3] if rel.endswith(".md") else rel,
            name,
            stem,
            name.lower(),
            stem.lower(),
            rel.lower(),
            (rel[:-3] if rel.endswith(".md") else rel).lower(),
        }
        for key in keys:
            mapping.setdefault(key, path)
    return mapping


def attachment_targets(vault: Path) -> set[str]:
    """Lowercased names and vault-relative paths of non-markdown files, for ![[image.png]] and [[file.pdf]]."""
    names: set[str] = set()
    for path in vault.rglob("*"):
        if path.is_symlink() or not path.is_file() or path.suffix.lower() == ".md":
            continue
        rel = path.relative_to(vault)
        if any(part in SKIP_DIRS or part.startswith(".") for part in rel.parts[:-1]):
            continue
        names.add(path.name.lower())
        names.add(rel.as_posix().lower())
    return names


def normalize_link(raw: str) -> str:
    target = raw.strip()
    if "|" in target:
        target = target.split("|", 1)[0].strip()
    if "#" in target:
        target = target.split("#", 1)[0].strip()
    return target


def is_wiki_page(path: Path, vault: Path) -> bool:
    rel = path.relative_to(vault)
    if len(rel.parts) == 1 and rel.name.lower() in SKIP_FRONTMATTER_TOP:
        return False
    if rel.parts[0] == "raw":
        return False
    if rel.parts[0] == "_templates":
        return False
    if rel.parts[0] == "_archive":
        return True
    if rel.parts[0] in WIKI_DIR_TYPES:
        return True
    # Other top-level markdown is left alone.
    return False


def default_status(path: Path, vault: Path) -> str | None:
    top = path.relative_to(vault).parts[0]
    if top in HISTORICAL_DIRS:
        return "historical"
    return None


def lint(vault: Path, today: dt.date, stale_days: int | None) -> list[str]:
    issues: list[str] = []
    files = iter_markdown(vault)
    targets = page_targets(vault, files)
    attachments = attachment_targets(vault)

    for path in files:
        rel = path.relative_to(vault).as_posix()
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            issues.append(f"encoding: {rel} is not valid UTF-8")
            continue
        except OSError as exc:
            issues.append(f"unreadable: {rel} ({exc})")
            continue

        fields, body = split_frontmatter(text)
        wiki = is_wiki_page(path, vault)

        if wiki:
            if fields is None:
                issues.append(f"frontmatter: {rel} has no YAML frontmatter")
            else:
                for key in REQUIRED_FIELDS:
                    value = (fields.get(key) or "").strip()
                    if not value:
                        issues.append(f"frontmatter: {rel} is missing {key}")
                status = (fields.get("status") or "").strip()
                if status and status not in VALID_STATUS:
                    issues.append(
                        f"frontmatter: {rel} has unknown status {status!r} (use current, superseded, or historical)"
                    )
                for date_key in ("created", "updated", "review_after"):
                    value = (fields.get(date_key) or "").strip()
                    if value and parse_date(value) is None:
                        issues.append(f"frontmatter: {rel} field {date_key} is not a real YYYY-MM-DD date ({value!r})")
                status_eff = status or default_status(path, vault) or "current"
                review = (fields.get("review_after") or "").strip()
                review_date = parse_date(review)
                if status_eff == "current" and review_date is not None:
                    if review_date < today:
                        issues.append(
                            f"stale: {rel} is current and review_after {review} is in the past"
                        )
                if stale_days is not None and status_eff == "current":
                    updated = (fields.get("updated") or "").strip()
                    updated_date = parse_date(updated)
                    if updated_date is not None:
                        age = (today - updated_date).days
                        if age > stale_days:
                            issues.append(
                                f"stale: {rel} is current and updated {updated} is {age} days old (threshold {stale_days})"
                            )

        # raw/ is append-once, so do not report wikilinks there (they cannot be "fixed").
        if path.relative_to(vault).parts[0] == "raw":
            continue

        searchable = strip_code(body if fields is not None else text)
        for match in WIKILINK_RE.finditer(searchable):
            target = normalize_link(match.group(1))
            if not target:
                continue
            keys = {target, target.lower()}
            if not target.endswith(".md"):
                keys.add(target + ".md")
                keys.add((target + ".md").lower())
            att_keys = {target.lower(), Path(target).name.lower()}
            if not any(key in targets for key in keys) and not any(k in attachments for k in att_keys):
                issues.append(f"broken-wikilink: {rel} points at [[{target}]] (no matching page)")

    return issues


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    vault = Path(args.vault).expanduser()
    if not vault.exists():
        print(f"error: vault not found: {vault}", file=sys.stderr)
        return 2
    if not vault.is_dir():
        print(f"error: vault is not a directory: {vault}", file=sys.stderr)
        return 2
    try:
        today = parse_today(args.today)
    except SystemExit as exc:
        print(str(exc), file=sys.stderr)
        return 2
    if args.stale_days is not None and args.stale_days < 0:
        print("error: --stale-days must be >= 0", file=sys.stderr)
        return 2

    issues = lint(vault.resolve(), today, args.stale_days)
    if not issues:
        print(f"lint: no issues found in {vault}")
        return 0
    print(f"lint: {len(issues)} issue(s) in {vault}")
    for item in issues:
        print(f"  - {item}")
    return 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
