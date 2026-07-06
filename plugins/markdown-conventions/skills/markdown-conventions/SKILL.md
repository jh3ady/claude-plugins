---
name: markdown-conventions
description: This skill should be used whenever writing or editing markdown (documentation, READMEs, specifications, changelogs, or markdown-formatted comments), even when conventions are not explicitly mentioned, applying a composable baseline of markdown formatting conventions (CommonMark, the markdownlint rule set, and Prettier defaults) and deferring to the project's own formatter configuration when present.
---

# Markdown conventions

A reusable standard for how markdown is formatted. Apply it by default. This
skill is the baseline standard, not an opinionated ruleset: compose it with
your own context (see "Adapt to your context" below).

## Defer to the project first

Before applying any default below, look for the project's own configuration and
follow it when it exists:

- A formatter configuration: `.prettierrc*` (or a `prettier` key in
  `package.json`), `dprint.json`, or `.markdownlint*` / `.markdownlint-cli2*`.
- An `.editorconfig` (indentation, final newline, trailing whitespace).

The project's configuration always wins over the defaults here. These
conventions only fill the gaps the project leaves unspecified.

## Default profile (when the project specifies nothing)

- Headings: ATX style (`#`), one space after the hashes, one blank line before
  and after. A single top-level heading per document.
- Blank lines: exactly one between block elements; none at the top of the file;
  a single trailing newline at the end.
- Lists: one consistent unordered marker throughout a document (`-` by
  default); ordered lists numbered `1.`, `2.`, `3.`; nested items indented by
  two spaces.
- Code: fenced blocks with a language tag, never indented code blocks; inline
  code in backticks.
- Emphasis: consistent markers (`**bold**`, `_italic_`); never emphasis in
  place of a heading.
- Whitespace: no trailing spaces (except a deliberate hard break); spaces, not
  tabs, for indentation.
- Line wrapping: do not hard-wrap prose by default; let it reflow. If the
  project sets a print width, follow it.
- Tables: pipe tables with a header separator row; column alignment optional.
- Links: prefer inline links; use reference links when the same target repeats.

For the rule-by-rule detail, the mapping to markdownlint rule numbers, and
before and after examples, read `references/conventions.md`.

## Enforcement hook

This plugin also ships a `PostToolUse` hook. After Claude edits a `.md` or
`.markdown` file, the hook runs the formatter the project already configures
(dprint, Prettier, or markdownlint-cli2, in that order) on that single file. It
does nothing when the project configures no formatter, so it never imposes a
style the project did not choose. The hook only reaches Claude's own edits, not
edits made by hand in an editor; this skill governs the rest.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Add a formatter configuration to your project to make the enforcement
  deterministic.
- Add team or personal rules (prose style, line width, heading case) in your
  own `CLAUDE.md` or a higher-priority skill. This skill does not impose them.
