---
name: commit-conventions
description: This skill should be used whenever writing or amending a commit message, preparing or splitting a commit, or writing a pull request or merge request title or description, even when conventions are not explicitly mentioned, applying the gitmoji + Conventional Commits standard (subject-based scopes, the Git 50/72 length rule) and the rule that public-facing text never cites an internal working artifact by code, number, or path.
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

## Never cite an internal working artifact

A commit message is read by people who do not have your plan, your board,
or your task list. Do not refer to a plan, a specification, a milestone, a
phase, a task, or a step by code, by number, or by path. `phase 1`,
`task 3`, `step 4`, `per the spec`, and `implement the kernel plan` all mean
nothing to a reader of the history, and they make it illegible the moment
the working document is renamed, closed, or deleted. State the actual
objective in plain words.

- Bad: `✨ feat: implement task 9 of phase 1`
- Good: `✨ feat(executors): add embedded cross-platform shell`

Two things are not covered by this rule. Cross-references between internal
documents are fine, because both sides travel together. And an issue or
pull request reference in a footer (`Refs: #123`, `Closes #123`) is fine,
because it points at something any reader of the repository can open.

The same rule governs pull request and merge request titles and
descriptions, issue titles, and changelog entries: everything a reader of
the project will see.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Define your project's scope vocabulary and keep it consistent.
- Add team or personal rules (attribution policy, author identity,
  required footers, allowed types) in your own `CLAUDE.md` or a
  higher-priority skill. This skill does not impose them.

## Reference

For the full Conventional Commits type list, the gitmoji-to-type pairing,
and worked examples, read `references/conventions.md`.
