# Clean code and software principles plugins: design

> **Addendum (2026-06-26):** Event sourcing, listed below as a future-work
> candidate plugin, has since been realised as the standalone `event-sourcing`
> plugin. CQRS remains a future candidate. The text below is preserved as the
> point-in-time record of the original decision.

- Date: 2026-06-25
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace already ships two convention
plugins (`commit-conventions`, `review-conventions`). They share a clear
pattern: a single generic, composable skill presented as a baseline
standard rather than a dogmatic ruleset, with depth pushed into
`references/`.

The goal of this work is to extend the marketplace with software
craftsmanship principles: clean code, SOLID, and the simplicity cluster
(KISS, DRY, YAGNI). These are distributed as separate, independently
installable plugins so users adopt them a la carte.

## Scope

This batch delivers three independent plugins:

1. `solid-principles`
2. `simplicity-principles`
3. `clean-code`

### Out of scope (future work)

Clean architecture is deliberately excluded from this batch. It is itself
decomposable into independent topics, each a candidate for its own plugin
in a later batch:

- `hexagonal-architecture`
- `ddd` (domain-driven design)
- `cqrs`
- `event-sourcing`
- `modular-monolith`

These are noted here only so the decomposition is recorded. They are not
designed or implemented in this batch.

## Key decisions

- **Decomposition: several independent plugins.** One plugin per theme,
  installable a la carte, consistent with the existing marketplace.
- **Activation: broad.** Each skill activates whenever production code is
  written or modified, and during reviews and refactorings. This maximizes
  coverage at the cost of more frequent loading.
- **Lean `SKILL.md`.** Because activation is broad, each skill loads often.
  The `SKILL.md` core must stay short and token-cheap: a tight set of
  heuristics and recognizable smells. Detailed definitions, before/after
  examples, and trade-offs live in `references/`.
- **Pragmatism baked in.** Each skill presents itself as a baseline grid of
  heuristics, not a dogma, echoing the guiding word PRAGMATISM. Every skill
  includes explicit guardrails against over-application (for example, do
  not introduce an interface for a single implementation in the name of
  dependency inversion). The level of sophistication must match the actual
  need.
- **Composability.** Each skill keeps an "Adapt to your context" section,
  like `commit-conventions`, so users layer their own rules on top.

## Shared plugin structure

Each plugin mirrors the existing plugins:

```
plugins/<plugin>/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  skills/<skill>/SKILL.md         # lean core: heuristics + broad activation description
  skills/<skill>/references/<topic>.md   # detailed definitions, before/after examples, guardrails
  README.md
  LICENSE                         # MIT
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as SOLID, DDD, CQRS, TDD are fine).

## Plugin contents

### `solid-principles`

The five SOLID principles (SRP, OCP, LSP, ISP, DIP).

- `SKILL.md`: for each principle, a recognizable symptom mapped to a
  pragmatic fix, plus anti-over-engineering guardrails (avoid speculative
  abstraction).
- `references/solid.md`: definition of each principle, one violation plus
  refactoring example each, and "when not to apply" notes.

### `simplicity-principles`

The "do less" cluster: KISS, DRY, YAGNI.

- `SKILL.md`: the three heuristics plus their key tensions (DRY versus
  coupling, captured by "duplication is cheaper than the wrong
  abstraction"; the rule of three; YAGNI versus genuine extensibility).
- `references/simplicity.md`: each principle, its trade-offs, and warning
  signals.

### `clean-code`

Craftsmanship in the Robert C. Martin sense.

- `SKILL.md`: naming, small functions (single responsibility, few
  arguments), comments (the why, not the what), error handling, boundaries
  and abstractions.
- `references/clean-code.md`: detailed guidance per area with examples.

## Research and validation approach

Each skill's content must be sourced and reviewed, not written from memory
alone.

- **Research.** Before authoring each skill, run research (web and
  reference sources) to ground the content in the recognized definitions
  and the well-known critiques and trade-offs of each principle (for
  example the "wrong abstraction" critique of DRY, the misuse of LSP, the
  over-application of SOLID). Capture sources.
- **Validation and review.** After authoring, review each skill's content
  for accuracy against the sources, internal consistency, and adherence to
  the pragmatism and composability framing. The implementation plan will
  specify how this review is carried out (for example, dedicated review
  passes or subagents), and the `skill-reviewer` agent can assess
  triggering quality.

## Authoring tools

At implementation time, use:

- `skill-creator` for skill scaffolding and structure best practices.
- `writing-skills` (superpowers) for frontmatter and description quality so
  the broad activation triggers reliably.

## Marketplace integration

- Add three entries to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add three rows to the root `README.md` plugins table.

## Success criteria

- Three installable plugins, each following the existing structure and
  conventions.
- Lean, broadly activating skills with depth in `references/`.
- Content grounded in researched sources and reviewed for accuracy.
- Pragmatism and composability framing present in every skill.
