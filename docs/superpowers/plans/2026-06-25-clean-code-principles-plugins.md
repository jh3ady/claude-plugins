# Clean code and software principles plugins Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add three independently installable Claude Code plugins (`solid-principles`, `simplicity-principles`, `clean-code`) to the `jh3ady-claude-plugins` marketplace, each a research-grounded, pragmatic, composable skill.

**Architecture:** Each plugin mirrors the two existing marketplace plugins: a single generic skill (`SKILL.md` lean core plus a `references/` deep dive), a `plugin.json` manifest, a `README.md`, and an MIT `LICENSE`. Content is sourced through a research step, then reviewed for accuracy before commit. The marketplace manifest and root README are updated last.

**Tech Stack:** Markdown skills, JSON manifests, git. No build system. Validation uses the `plugin-validator` and `skill-reviewer` agents plus JSON parsing.

## Global Constraints

- Writing conventions: all files in English; no em-dashes; words written in full (standard acronyms such as SOLID, DDD, CQRS, TDD, SRP, OCP, LSP, ISP, DIP, KISS, DRY, YAGNI are allowed).
- Each plugin `version` is `0.1.0`; license is MIT.
- `author`: `{ "name": "Jean-Denis VIDOT", "url": "https://github.com/jh3ady" }`.
- `homepage`: `https://github.com/jh3ady/claude-plugins/tree/main/plugins/<plugin>`.
- Activation is broad: each skill description triggers on writing, modifying, reviewing, or refactoring production code, even when the principle is not named.
- `SKILL.md` core stays lean and token-cheap; detail lives in `references/`.
- Pragmatism and composability framing present in every skill: a baseline grid of heuristics, not a dogma; explicit guardrails against over-application; an "Adapt to your context" section.
- Never add Claude self-promotion or `Co-Authored-By` trailers.
- Commit messages: gitmoji + Conventional Commits, lower-case verb summary.
- Work happens on the existing branch `feat/clean-code-principles-plugins`.

---

## File Structure

Created per plugin `<p>` in `plugins/<p>/` (where `<p>` is the plugin name, equal to the skill name):

- `.claude-plugin/plugin.json` — manifest
- `skills/<p>/SKILL.md` — lean skill core
- `skills/<p>/references/<topic>.md` — deep dive (`solid.md`, `simplicity.md`, `clean-code.md`)
- `README.md` — plugin readme
- `LICENSE` — copied verbatim from an existing plugin

Modified once, in the final task:

- `.claude-plugin/marketplace.json` — three new plugin entries
- `README.md` (root) — three new table rows

Research briefs are written to the scratchpad (not committed):
`/private/tmp/claude-501/-Users-jh3ady--config-claude-plugins/32ab2e7f-3deb-4807-a1c0-4a1d04c37615/scratchpad/research-<topic>.md`

---

### Task 1: `solid-principles` plugin

**Files:**
- Create: `plugins/solid-principles/.claude-plugin/plugin.json`
- Create: `plugins/solid-principles/skills/solid-principles/SKILL.md`
- Create: `plugins/solid-principles/skills/solid-principles/references/solid.md`
- Create: `plugins/solid-principles/README.md`
- Create: `plugins/solid-principles/LICENSE`

**Interfaces:**
- Produces: a plugin directory named `solid-principles` with a skill named `solid-principles`, consumed by Task 4's marketplace entry and root README row.

- [ ] **Step 1: Research SOLID, grounded and critical**

Dispatch a research subagent (general-purpose) with web access. Prompt it to return a brief covering, for each of SRP, OCP, LSP, ISP, DIP:
- the canonical definition and its origin (Robert C. Martin / the recognized formulations);
- one concise recognizable smell (symptom in code);
- one focused refactoring that resolves it;
- the main over-application failure mode (for example: speculative interfaces for a single implementation under DIP/ISP; premature OCP abstraction; class-explosion under SRP) and a "when not to apply" note;
- 3 to 6 citable sources (title plus URL).

Save the returned brief to `scratchpad/research-solid.md`.

- [ ] **Step 2: Verify the research brief is usable**

Confirm `scratchpad/research-solid.md` exists and contains all five principles, each with definition, smell, refactoring, over-application note, and that there are at least 3 sources. If anything is missing, re-dispatch with the gaps named.

- [ ] **Step 3: Scaffold the plugin manifest, README, and LICENSE**

Create `plugins/solid-principles/.claude-plugin/plugin.json`:

```json
{
  "name": "solid-principles",
  "version": "0.1.0",
  "description": "The five SOLID principles applied pragmatically: recognizable smells, focused refactorings, and guardrails against speculative abstraction. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/solid-principles",
  "keywords": [
    "solid",
    "clean-code",
    "software-design",
    "srp",
    "ocp",
    "lsp",
    "isp",
    "dip"
  ]
}
```

Create `plugins/solid-principles/README.md`:

```markdown
# solid-principles

A Claude Code plugin that applies the five SOLID principles (SRP, OCP,
LSP, ISP, DIP) to the code you write and review, pragmatically: it
recognizes the smell, proposes a focused refactoring, and keeps you from
over-engineering.

It stays generic on purpose: compose it with your own project conventions
and your team or personal rules.

## What it does

When you write, modify, review, or refactor production code, the bundled
skill applies:

- A recognizable symptom for each SOLID principle, mapped to a focused fix.
- Guardrails against speculative abstraction (no interface for a single
  implementation just to satisfy a principle).
- The pragmatic rule: match the level of sophistication to the actual need.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install solid-principles@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline grid of heuristics, not a dogma. Layer your own
architecture rules and team conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
```

Copy the license:

```bash
cp plugins/commit-conventions/LICENSE plugins/solid-principles/LICENSE
```

- [ ] **Step 4: Author the reference deep dive**

Write `plugins/solid-principles/skills/solid-principles/references/solid.md` from `scratchpad/research-solid.md`. Required structure:
- a short intro naming the source standard and linking the cited sources;
- one section per principle (SRP, OCP, LSP, ISP, DIP), each containing: definition in one or two sentences; a "Smell" subsection with a short before example; a "Fix" subsection with the refactored after example; a "When not to apply" note;
- a closing "Pragmatism" section restating that the principles serve the product and must not be applied blindly.
Use fenced code blocks for the before/after examples. Keep examples language-agnostic or in a common language (for example TypeScript). No em-dashes; full words.

- [ ] **Step 5: Author the lean SKILL.md**

Invoke `skill-creator` and `writing-skills` (superpowers) for structure and description quality, then write `plugins/solid-principles/skills/solid-principles/SKILL.md`. Frontmatter:

```markdown
---
name: solid-principles
description: Apply the five SOLID principles (SRP, OCP, LSP, ISP, DIP) when writing, modifying, reviewing, or refactoring production code, even when SOLID is not explicitly mentioned. Includes pragmatic guardrails against over-engineering and speculative abstraction.
---
```

Body requirements (lean, scannable, under roughly 60 lines):
- one-line framing: baseline heuristics, applied pragmatically, not a dogma;
- a compact list, one entry per principle: `PRINCIPLE — smell to watch for -> the focused fix`;
- a short "Guardrails" section: do not abstract speculatively; prefer the simplest design that meets the current need; a principle that adds indirection without a present payoff is over-application;
- an "Adapt to your context" section (compose with the user's own rules);
- a final line pointing to `references/solid.md` for definitions, before/after examples, and "when not to apply" notes.

- [ ] **Step 6: Validate JSON and plugin structure**

Run:

```bash
python3 -m json.tool plugins/solid-principles/.claude-plugin/plugin.json > /dev/null && echo "plugin.json OK"
```

Expected: `plugin.json OK`. Then dispatch the `plugin-dev:plugin-validator` agent on `plugins/solid-principles` and resolve any reported structural issues.

- [ ] **Step 7: Review skill quality and content accuracy**

Dispatch the `plugin-dev:skill-reviewer` agent on the skill, and a content-review subagent that checks `SKILL.md` and `references/solid.md` against `scratchpad/research-solid.md` for accuracy, internal consistency, the pragmatism framing, and the writing conventions (English, no em-dashes, full words). Fix any issues raised.

- [ ] **Step 8: Commit**

```bash
git add plugins/solid-principles
git commit -m "✨ feat: add solid-principles plugin"
```

---

### Task 2: `simplicity-principles` plugin

**Files:**
- Create: `plugins/simplicity-principles/.claude-plugin/plugin.json`
- Create: `plugins/simplicity-principles/skills/simplicity-principles/SKILL.md`
- Create: `plugins/simplicity-principles/skills/simplicity-principles/references/simplicity.md`
- Create: `plugins/simplicity-principles/README.md`
- Create: `plugins/simplicity-principles/LICENSE`

**Interfaces:**
- Produces: a plugin directory named `simplicity-principles` with a skill named `simplicity-principles`, consumed by Task 4.

- [ ] **Step 1: Research KISS, DRY, YAGNI with their tensions**

Dispatch a research subagent (general-purpose, web access). Prompt it to return a brief covering, for each of KISS, DRY, YAGNI:
- the canonical definition and origin;
- one recognizable smell and one focused fix;
- the key trade-off and failure mode, specifically: DRY versus coupling (the "duplication is cheaper than the wrong abstraction" critique, Sandi Metz) and the rule of three; YAGNI versus genuine extensibility; KISS versus accidental cleverness;
- 3 to 6 citable sources (title plus URL).

Save to `scratchpad/research-simplicity.md`.

- [ ] **Step 2: Verify the research brief is usable**

Confirm `scratchpad/research-simplicity.md` covers all three principles with definition, smell, fix, and the named trade-offs (including the wrong-abstraction critique and the rule of three), and has at least 3 sources. Re-dispatch for any gap.

- [ ] **Step 3: Scaffold the plugin manifest, README, and LICENSE**

Create `plugins/simplicity-principles/.claude-plugin/plugin.json`:

```json
{
  "name": "simplicity-principles",
  "version": "0.1.0",
  "description": "The simplicity cluster KISS, DRY, and YAGNI applied pragmatically: do-less heuristics, the rule of three, and the trade-offs such as duplication versus the wrong abstraction. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/simplicity-principles",
  "keywords": [
    "kiss",
    "dry",
    "yagni",
    "clean-code",
    "simplicity",
    "software-design"
  ]
}
```

Create `plugins/simplicity-principles/README.md`:

```markdown
# simplicity-principles

A Claude Code plugin that applies the simplicity cluster, KISS, DRY, and
YAGNI, to the code you write and review, pragmatically: it favors the
simplest design that meets the current need and surfaces the trade-offs
before you abstract.

It stays generic on purpose: compose it with your own project conventions
and your team or personal rules.

## What it does

When you write, modify, review, or refactor production code, the bundled
skill applies:

- KISS, DRY, and YAGNI as do-less heuristics with recognizable smells.
- The rule of three and the warning that duplication is cheaper than the
  wrong abstraction.
- The pragmatic rule: match the level of sophistication to the actual need.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install simplicity-principles@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline grid of heuristics, not a dogma. Layer your own
architecture rules and team conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
```

Copy the license:

```bash
cp plugins/commit-conventions/LICENSE plugins/simplicity-principles/LICENSE
```

- [ ] **Step 4: Author the reference deep dive**

Write `plugins/simplicity-principles/skills/simplicity-principles/references/simplicity.md` from `scratchpad/research-simplicity.md`. Required structure:
- short intro naming sources and linking them;
- one section per principle (KISS, DRY, YAGNI), each with: definition; "Smell" with a short before example; "Fix" with the after example; "Trade-off" capturing the tension (for DRY: the rule of three and the wrong-abstraction critique; for YAGNI: when extensibility is genuinely warranted; for KISS: avoiding accidental cleverness);
- a closing "Pragmatism" section.
Fenced code blocks for examples. No em-dashes; full words.

- [ ] **Step 5: Author the lean SKILL.md**

Invoke `skill-creator` and `writing-skills`, then write `plugins/simplicity-principles/skills/simplicity-principles/SKILL.md`. Frontmatter:

```markdown
---
name: simplicity-principles
description: Apply the simplicity principles KISS, DRY, and YAGNI when writing, modifying, reviewing, or refactoring production code, even when they are not explicitly mentioned. Includes the rule of three and the trade-off between duplication and the wrong abstraction.
---
```

Body requirements (lean, under roughly 60 lines):
- one-line framing: do less, but not blindly;
- a compact list, one entry per principle: `PRINCIPLE — smell -> the focused fix`;
- a "Trade-offs" section: the rule of three before extracting a shared abstraction; duplication is cheaper than the wrong abstraction; YAGNI defers speculative work but does not forbid genuine, near-term extensibility;
- an "Adapt to your context" section;
- a final line pointing to `references/simplicity.md`.

- [ ] **Step 6: Validate JSON and plugin structure**

Run:

```bash
python3 -m json.tool plugins/simplicity-principles/.claude-plugin/plugin.json > /dev/null && echo "plugin.json OK"
```

Expected: `plugin.json OK`. Then dispatch `plugin-dev:plugin-validator` on `plugins/simplicity-principles` and resolve issues.

- [ ] **Step 7: Review skill quality and content accuracy**

Dispatch `plugin-dev:skill-reviewer` on the skill, and a content-review subagent checking `SKILL.md` and `references/simplicity.md` against `scratchpad/research-simplicity.md` for accuracy, consistency, framing, and conventions. Fix issues.

- [ ] **Step 8: Commit**

```bash
git add plugins/simplicity-principles
git commit -m "✨ feat: add simplicity-principles plugin"
```

---

### Task 3: `clean-code` plugin

**Files:**
- Create: `plugins/clean-code/.claude-plugin/plugin.json`
- Create: `plugins/clean-code/skills/clean-code/SKILL.md`
- Create: `plugins/clean-code/skills/clean-code/references/clean-code.md`
- Create: `plugins/clean-code/README.md`
- Create: `plugins/clean-code/LICENSE`

**Interfaces:**
- Produces: a plugin directory named `clean-code` with a skill named `clean-code`, consumed by Task 4.

- [ ] **Step 1: Research clean code craftsmanship**

Dispatch a research subagent (general-purpose, web access). Prompt it to return a brief covering each area: naming; small functions (single responsibility, few arguments); comments (why not what, and the dead-code/redundant-comment smells); error handling (exceptions over error codes, do not return or pass null where it can be avoided); boundaries and abstractions. For each area: one recognizable smell, one focused fix, and the main over-application failure mode (for example dogmatic tiny-function fragmentation, or banning all comments). Include 3 to 6 citable sources (title plus URL), grounded in Robert C. Martin's Clean Code and recognized critiques.

Save to `scratchpad/research-clean-code.md`.

- [ ] **Step 2: Verify the research brief is usable**

Confirm `scratchpad/research-clean-code.md` covers all five areas, each with smell, fix, and an over-application note, and has at least 3 sources. Re-dispatch for any gap.

- [ ] **Step 3: Scaffold the plugin manifest, README, and LICENSE**

Create `plugins/clean-code/.claude-plugin/plugin.json`:

```json
{
  "name": "clean-code",
  "version": "0.1.0",
  "description": "Clean code craftsmanship applied pragmatically: naming, small focused functions, intent-revealing comments, and disciplined error handling. Composable with your own conventions.",
  "author": {
    "name": "Jean-Denis VIDOT",
    "url": "https://github.com/jh3ady"
  },
  "license": "MIT",
  "homepage": "https://github.com/jh3ady/claude-plugins/tree/main/plugins/clean-code",
  "keywords": [
    "clean-code",
    "naming",
    "functions",
    "refactoring",
    "craftsmanship",
    "software-design"
  ]
}
```

Create `plugins/clean-code/README.md`:

```markdown
# clean-code

A Claude Code plugin that applies clean code craftsmanship to the code you
write and review, pragmatically: clear names, small focused functions,
intent-revealing comments, and disciplined error handling, without
dogmatic fragmentation.

It stays generic on purpose: compose it with your own project conventions
and your team or personal rules.

## What it does

When you write, modify, review, or refactor production code, the bundled
skill applies:

- Naming, function size and shape, comments, and error handling heuristics.
- A recognizable smell for each area, mapped to a focused fix.
- The pragmatic rule: match the level of sophistication to the actual need.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install clean-code@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline grid of heuristics, not a dogma. Layer your own
style guide and team conventions in your own `CLAUDE.md` or a
higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
```

Copy the license:

```bash
cp plugins/commit-conventions/LICENSE plugins/clean-code/LICENSE
```

- [ ] **Step 4: Author the reference deep dive**

Write `plugins/clean-code/skills/clean-code/references/clean-code.md` from `scratchpad/research-clean-code.md`. Required structure:
- short intro naming sources and linking them;
- one section per area (Naming, Functions, Comments, Error handling, Boundaries), each with: a one or two sentence rule; "Smell" with a short before example; "Fix" with the after example; an over-application caution;
- a closing "Pragmatism" section.
Fenced code blocks for examples. No em-dashes; full words.

- [ ] **Step 5: Author the lean SKILL.md**

Invoke `skill-creator` and `writing-skills`, then write `plugins/clean-code/skills/clean-code/SKILL.md`. Frontmatter:

```markdown
---
name: clean-code
description: Apply clean code craftsmanship (naming, small focused functions, intent-revealing comments, error handling) when writing, modifying, reviewing, or refactoring production code, even when clean code is not explicitly mentioned. Pragmatic, not dogmatic fragmentation.
---
```

Body requirements (lean, under roughly 60 lines):
- one-line framing: readable by default, applied pragmatically;
- a compact list, one entry per area: `AREA — smell -> the focused fix`;
- a "Guardrails" section: do not fragment into trivially small functions for their own sake; comments explain intent that code cannot, they are not banned; the simplest readable design wins;
- an "Adapt to your context" section;
- a final line pointing to `references/clean-code.md`.

- [ ] **Step 6: Validate JSON and plugin structure**

Run:

```bash
python3 -m json.tool plugins/clean-code/.claude-plugin/plugin.json > /dev/null && echo "plugin.json OK"
```

Expected: `plugin.json OK`. Then dispatch `plugin-dev:plugin-validator` on `plugins/clean-code` and resolve issues.

- [ ] **Step 7: Review skill quality and content accuracy**

Dispatch `plugin-dev:skill-reviewer` on the skill, and a content-review subagent checking `SKILL.md` and `references/clean-code.md` against `scratchpad/research-clean-code.md` for accuracy, consistency, framing, and conventions. Fix issues.

- [ ] **Step 8: Commit**

```bash
git add plugins/clean-code
git commit -m "✨ feat: add clean-code plugin"
```

---

### Task 4: Marketplace and root README integration

**Files:**
- Modify: `.claude-plugin/marketplace.json` (append three entries to `plugins`)
- Modify: `README.md` (append three rows to the plugins table)

**Interfaces:**
- Consumes: the three plugin directories and their exact `name` and `description` values from Tasks 1 to 3.

- [ ] **Step 1: Add the three marketplace entries**

In `.claude-plugin/marketplace.json`, append to the `plugins` array, after the `review-conventions` entry, keeping the existing two untouched:

```json
    {
      "name": "solid-principles",
      "source": "./plugins/solid-principles",
      "description": "The five SOLID principles applied pragmatically: recognizable smells, focused refactorings, and guardrails against speculative abstraction. Composable with your own conventions.",
      "version": "0.1.0"
    },
    {
      "name": "simplicity-principles",
      "source": "./plugins/simplicity-principles",
      "description": "The simplicity cluster KISS, DRY, and YAGNI applied pragmatically: do-less heuristics, the rule of three, and the trade-offs such as duplication versus the wrong abstraction. Composable with your own conventions.",
      "version": "0.1.0"
    },
    {
      "name": "clean-code",
      "source": "./plugins/clean-code",
      "description": "Clean code craftsmanship applied pragmatically: naming, small focused functions, intent-revealing comments, and disciplined error handling. Composable with your own conventions.",
      "version": "0.1.0"
    }
```

- [ ] **Step 2: Add the three root README rows**

In `README.md`, append to the plugins table, after the `review-conventions` row:

```markdown
| [`solid-principles`](plugins/solid-principles) | The five SOLID principles applied pragmatically: recognizable smells, focused refactorings, guardrails against over-engineering. |
| [`simplicity-principles`](plugins/simplicity-principles) | KISS, DRY, and YAGNI applied pragmatically: do-less heuristics, the rule of three, duplication versus the wrong abstraction. |
| [`clean-code`](plugins/clean-code) | Clean code craftsmanship applied pragmatically: naming, small focused functions, intent-revealing comments, error handling. |
```

- [ ] **Step 3: Validate the marketplace manifest**

Run:

```bash
python3 -m json.tool .claude-plugin/marketplace.json > /dev/null && echo "marketplace.json OK"
```

Expected: `marketplace.json OK`. Confirm the array now lists five plugins and that each `source` path exists:

```bash
for p in commit-conventions review-conventions solid-principles simplicity-principles clean-code; do test -f "plugins/$p/.claude-plugin/plugin.json" && echo "$p OK"; done
```

Expected: five `OK` lines.

- [ ] **Step 4: Commit**

```bash
git add .claude-plugin/marketplace.json README.md
git commit -m "📝 docs: register the three principles plugins in the marketplace"
```

---

## Self-Review

**1. Spec coverage:**
- Three independent plugins (`solid-principles`, `simplicity-principles`, `clean-code`): Tasks 1 to 3.
- Shared structure mirroring existing plugins: each task's Steps 3 to 5.
- Broad activation and lean `SKILL.md`: Step 5 of each plugin task (frontmatter plus line budget).
- Pragmatism and composability framing: required in every SKILL.md and reference, plus README "Adapt to your context".
- Research then validation/review: Steps 1 to 2 (research) and Steps 6 to 7 (validate and review) of each plugin task.
- Authoring tools (`skill-creator`, `writing-skills`): Step 5 of each plugin task.
- Marketplace and root README integration: Task 4.
- Clean architecture out of scope: not implemented; recorded only in the spec.

**2. Placeholder scan:** No "TBD" or "add appropriate X". Content steps specify exact required sections and constraints; manifests, READMEs, and table rows are given verbatim. Skill and reference prose is intentionally research-driven, with concrete acceptance criteria rather than fixed text.

**3. Type consistency:** Plugin names, skill names, directory paths, `source` paths, homepages, and descriptions are identical across the plugin task that creates them and the Task 4 entry that references them.
