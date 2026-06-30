---
name: commit-conventions
description: This skill should be used whenever writing or amending a commit message, or preparing or splitting a commit, even when conventions are not explicitly mentioned, applying the gitmoji + Conventional Commits standard to commit messages (subject-based scopes and the Git 50/72 length rule).
---

# Commit conventions

A reusable standard for commit messages. Apply it by default. This skill is
the baseline standard, not an opinionated ruleset: compose it with your own
context (see "Adapt to your context" below).

## Format

`<gitmoji> <type>(<optional scope>): <summary>`

- gitmoji and type are chosen separately. The emoji shows intent; the type
  is the Conventional Commits category. Do not infer the type from the
  emoji: initializing a repository uses the party emoji but the type is
  `chore`, not `feat`, because setup is not a user-facing feature.
- Summary: imperative mood, no trailing period. Start with a lower-case
  verb (`add`, `remove`, `write`); keep proper nouns and acronyms in their
  natural case (`Git`, `English`, `CLAUDE.md`, `TDD`).
- Length (the Git 50/72 rule): keep the subject under 50 characters when
  possible, 72 maximum; wrap the body at 72 columns. The gitmoji, type,
  and scope all count toward the subject budget, so push detail into the
  body rather than stretching the subject.
- One commit per subject: do not bundle unrelated changes.

## Scopes

Scope by the change's subject, not by the files it happens to touch.
Derive the scope from the project's own areas (for example `auth`, `api`,
`ui`, `db`). Omit the scope only for genuinely repository-wide changes.
Each repository defines its own scope vocabulary; keep it consistent
within a repository.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Define your project's scope vocabulary and keep it consistent.
- Add team or personal rules (attribution policy, author identity,
  required footers, allowed types) in your own `CLAUDE.md` or a
  higher-priority skill. This skill does not impose them.

## Reference

For the full Conventional Commits type list, the gitmoji-to-type pairing,
and worked examples, read `references/conventions.md`.
