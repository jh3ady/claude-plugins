# Using impeccable-paper

A complete guide to designing in Paper (paper.design) with the
`impeccable-paper` skill: setup, invocation, every command with example
prompts, the main workflows, and troubleshooting.

## Contents

- [What it is](#what-it-is)
- [Prerequisites](#prerequisites)
- [Invoking the skill](#invoking-the-skill)
- [Core concepts](#core-concepts)
- [Command reference](#command-reference)
- [Workflows](#workflows)
- [Review comments](#review-comments)
- [Design tokens](#design-tokens)
- [Troubleshooting](#troubleshooting)
- [Relationship to Impeccable and paper-desktop](#relationship-to-impeccable-and-paper-desktop)

## What it is

`impeccable-paper` makes Claude behave as a demanding design director inside
Paper: it reads your canvas through the Paper MCP server, commits to a clear
visual direction before drawing, builds fully committed artboards, verifies
its work against measured values and screenshots in bounded rounds, and
refines through a vocabulary of named commands. It designs on the canvas; it
does not write production code.

## Prerequisites

1. **Paper Desktop** installed (https://paper.design/downloads), with a file
   open. Opening a file starts the local MCP server.
2. **The Paper MCP connection** in Claude Code, through the official plugin
   (recommended):

   ```
   /plugin marketplace add paper-design/agent-plugins
   /plugin install paper-desktop@paper
   ```

   or manually:

   ```
   claude mcp add paper --transport http http://127.0.0.1:29979/mcp --scope user
   ```

   Use one of the two, not both, or the Paper tools appear twice.
3. **This plugin**:

   ```
   /plugin marketplace add jh3ady/claude-plugins
   /plugin install jh3ady-impeccable-paper@jh3ady-claude-plugins
   ```

## Invoking the skill

Three ways, from most to least explicit:

- **Slash command with a sub-command**:
  `/jh3ady-impeccable-paper:impeccable-paper critique the pricing artboard`.
- **Slash command alone**: `/jh3ady-impeccable-paper:impeccable-paper`. The skill
  reads the canvas and recommends the highest-value next commands instead of
  acting on its own.
- **Natural language**: any design request about Paper triggers it. "Design a
  landing page for my product in Paper", "make this section bolder", "review
  the selected frame".

**Selection is the best brief.** Select the frame or node in Paper before
asking; the skill reads your selection first and never has to guess which
artboard you mean. You can also name a frame ("the Hero artboard") or
describe content ("the card that says Get started"); the skill finds it.

## Core concepts

- **Modes.** Every surface is designed for what its visitor's success looks
  like: **Persuade** (landing pages, marketing: the visitor decides and
  acts), **Operate** (app UI, dashboards: the visitor completes a task),
  **Read** (docs, articles: the visitor understands), **Experience**
  (portfolios, showcases: the visitor is inside the work). The mode follows
  the surface, not the product.
- **The visual world.** New work commits to one coherent direction (palette,
  materials, type voice, component language) chosen with you before
  building, and records it as a `Direction contract` text frame beside the
  artboard. Refinement inherits the incumbent world; redesign replaces it on
  a new artboard beside the original, never destructively.
- **The craft floor.** A quality floor checked on the built result: contrast
  measured from computed styles (never eyeballed), one spacing rhythm, a
  deliberate type scale, real content, named layers, and a refuse list of
  AI-default patterns (eyebrow labels, gradient text, nested cards, emoji as
  icons, and the rest).
- **Bounded verification.** The skill builds fully, inspects once with a
  batched screenshot round, fixes everything in one batch, confirms with at
  most one more round, and stops. It will not loop screenshots on your
  budget; for a fresh pair of eyes, ask for `critique`.

## Command reference

Sub-commands accept an optional target (an artboard or node name, a content
description, or your current selection).

### Build

- **`shape [feature]`**: a short discovery interview, then a confirmed
  design brief. No canvas edits. Use it when the request is still fuzzy.
  "Shape the onboarding flow before we design it."
- **`craft [feature]`**: design a new surface, committing to a visual world
  with you first (directions presented for choice, category standard always
  available as an option). "Craft a pricing page for Valora."
- **`variants [target]`**: duplicate the target and build 2 to 4 genuinely
  different directions side by side, then let you pick. "Give me three
  variants of this hero."
- **`adapt [target]`**: derive the surface at other device widths as sibling
  frames, restructuring rather than shrinking. "Adapt the dashboard for
  mobile 390."

### Evaluate

- **`critique [target]`**: a design review from screenshots, structure, and
  measured styles: Nielsen heuristics scored 0 to 4, cognitive load,
  specificity verdict, findings ranked P0 to P3, open team comments
  cross-referenced. Read-only. "Critique the checkout artboard."
- **`audit [target]`**: the mechanical subset only: contrast ratios, type
  scale, spacing, refuse-list hits, layer hygiene, with exact nodes and
  values. Fast and repeatable. "Audit contrast on this frame."

### Refine

All refinement commands preserve the incumbent identity and everything
outside scope, patch surgically, and offer `polish` when done.

- **`polish [target]`**: the final quality pass; also picks up open review
  comments and prior critique findings as its backlog. "Polish the settings
  page before the demo."
- **`bolder [target]`**: amplify a flat region using the system's own
  strongest moves, no new primitives. "This section feels timid, make it
  bolder."
- **`quieter [target]`**: reduce intensity with precision; luxury, not
  laziness. "Tone down the dashboard, it screams."
- **`distill [target]`**: strip to essence; every element must justify
  itself. "Distill this form, it does too much."
- **`layout [target]`**: reading order, grouping, rhythm, density. "Fix the
  spacing rhythm of the features grid."
- **`typeset [target]`**: typographic roles, hierarchy, measure, faces
  confirmed against the fonts Paper can actually render. "Improve the
  typography of the article frame."
- **`colorize [target]`**: color as hierarchy, meaning, and atmosphere, with
  measured contrast. "Add color to this grayscale wireframe."
- **`delight [target]`**: product character at moments that earn it, never
  generic whimsy. "Give the empty state some personality."
- **`clarify [target]`**: interface copy: labels, errors, empty states,
  destructive confirmations. "Rewrite the error messages on this flow."

### System

- **`extract [target]`**: consolidate repeated values into Paper's native
  design tokens (typed CSS custom properties), then migrate every usage onto
  `var()` references. "Extract the design tokens from these artboards."

### Handoff

- **`export [target]`**: export PNG, JPG, SVG, or MP4 at the right scale for
  the intended use. "Export the hero at 2x for the deck." For production
  code, use the `design-to-code` skill from the official `paper-desktop`
  plugin; it reads exact structure and values through the MCP server.

## Workflows

**From nothing to a shipped design.** Open an empty Paper file, then:
`shape` (brief) then `craft` (direction choice, build) then `critique`
(fresh review) then `polish` (close the findings) then `export` or
`design-to-code`. For a well-understood surface, skip `shape` and start at
`craft`.

**Exploring before committing.** Build one version (or start from an
existing frame), then `variants` on the region in question; pick a winner;
`polish` it; delete or keep the losers.

**The team review loop.** Teammates leave comments in Paper; you ask for
`polish` on the commented frame. The skill reads every open thread, fixes
what it can, resolves the threads it fully addressed, and reports the rest.
`critique` also cross-references open threads so team feedback and the
skill's findings land in one ranked list.

**Tokenizing a grown file.** Once a file has a few settled artboards, run
`extract`: the skill finds the repeated values, proposes a named vocabulary
(semantic roles over primitives), creates the tokens, and migrates the
canvas onto them. Design-to-code then inherits clean token names.

**Responsive coverage.** Design the primary width first, `polish` it, then
`adapt` to the other devices; each width is restructured, not scaled.

## Review comments

The Paper MCP server reads and resolves comment threads; it cannot create
them. In practice:

- The skill treats open threads on a target as the first backlog for any
  refinement work there, and reads full threads before acting (replies often
  change the ask).
- When an edit fully addresses a thread, the skill marks it resolved and
  says so; partially addressed threads stay open.
- `critique` reports in chat and can summarize onto a canvas text frame on
  request; it never promises to post comments, because it cannot.

## Design tokens

Paper tokens are typed CSS custom properties (color, spacing, fontSize,
fontWeight, fontFamily, lineHeight, letterSpacing, radius, container,
breakpoint) consumed as `var(--token-name)`. The skill reads the vocabulary
before styling in a tokenized file, styles with tokens where they exist, and
grows the vocabulary through `extract` rather than scattering literals. If
your codebase has design tokens too, mention it: the skill keeps the two
vocabularies aligned so handoff preserves names.

## Troubleshooting

- **"Connection failed" on any Paper tool**: Paper Desktop is not running or
  no file is open. Open the file and retry; the skill retries once on its
  own and then asks.
- **A font renders wrong**: the skill checks availability with Paper's font
  info before committing to a face, but a file moved between machines can
  lose fonts; install the face or ask for `typeset` to re-resolve.
- **The skill edits the wrong frame**: select the intended frame in Paper
  and re-ask; selection beats every other form of targeting.
- **Duplicate Paper tools in the session**: both the `paper-desktop` plugin
  and a manual `claude mcp add paper` registration are active; remove one
  (`claude mcp remove paper --scope user`).
- **The skill refuses to keep polishing**: by design. Verification is
  bounded; ask for `critique` to get a fresh, independent pass instead of
  more self-review.

## Relationship to Impeccable and paper-desktop

- [Impeccable](https://impeccable.style) is the original skill this plugin
  adapts; it designs in frontend code. Use Impeccable in a codebase,
  `impeccable-paper` on a Paper canvas. The philosophy, quality floor, and
  command vocabulary are shared.
- The official `paper-desktop` plugin provides the MCP connection and the
  two bridge skills: `code-to-design` (seed a Paper design from your
  codebase's tokens and components) and `design-to-code` (turn a finished
  frame into production code). `impeccable-paper` covers everything between
  those two bridges: making the design on the canvas excellent.
