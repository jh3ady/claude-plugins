# Modular monolith plugin: design

- Date: 2026-06-25
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`). They share one
pattern: a single generic, composable skill presented as a pragmatic
baseline rather than a dogma, with depth pushed into `references/`.

This work adds one plugin to that family: `modular-monolith`. It was
recorded as future work in the clean-code batch design (alongside
`hexagonal-architecture`, `ddd`, `cqrs`, `event-sourcing`) and is now
designed and implemented on its own.

The goal is a skill that helps structure an application as a single
deployable unit with strictly bounded internal modules, applied
pragmatically, and clearly distinguished from both the unstructured
monolith ("big ball of mud") and microservices.

## Scope

One independent, a la carte plugin: `modular-monolith`.

### Boundary of the topic (focused, with references out)

The skill covers the modular monolith proper and nothing more:

- module boundaries (public API versus internal implementation);
- inter-module communication (direct call by default, in-process events
  only when decoupling or eventual consistency is wanted deliberately);
- data isolation (schema per module, no cross-module foreign keys, joins,
  or transactions);
- boundary enforcement in the TypeScript/Node ecosystem;
- the path from module to extracted microservice.

Adjacent patterns are referenced as complementary, never absorbed:

- **DDD bounded contexts**: a strategy for where to place boundaries. A
  module can be treated as a bounded context, but DDD is not a prerequisite.
- **Hexagonal / ports and adapters**: a per-module internal structuring
  choice, decided module by module.
- **CQRS / event sourcing**: optional, orthogonal.

This keeps the marketplace invariant "one topic = one plugin".

## Key decisions

- **One independent plugin**, installable a la carte, consistent with the
  existing marketplace.
- **Activation: design-and-review oriented.** The skill activates when
  structuring or reviewing application architecture, module boundaries,
  or deployment topology, and when weighing monolith versus microservices.
  This is narrower than the always-on code-writing skills, because the
  topic is architectural rather than line-by-line.
- **Lean `SKILL.md`.** The core stays short and token-cheap: the one-line
  definition, the three invariants, pragmatic guardrails, and references-out
  to complementary patterns. Definitions, examples, trade-offs, and sources
  live in `references/`.
- **Pragmatism baked in.** The skill presents a baseline, not a dogma, and
  includes explicit guardrails against over-engineering: start with coarse
  modules and let a module earn its independence, do not apply heavy DDD or
  hexagonal patterns to a CRUD module, do not make everything event-driven
  in-process.
- **Contested axes presented as deliberate choices, not imposed camps.**
  Two points are genuinely contested in the sources: direct call versus
  in-process events, and one database with schemas versus multiple
  databases. The skill states the shared rule ("data must be logically
  isolated; choose the physical and communication style deliberately, and
  default to the simplest") rather than mandating one camp.
- **Composability.** An "Adapt to your context" section, like the other
  plugins, so users layer their own module rules on top.
- **Examples in TypeScript only**, consistent with the rest of the family.

## Plugin structure

Mirrors the existing plugins:

```
plugins/modular-monolith/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  skills/modular-monolith/SKILL.md          # lean core
  skills/modular-monolith/references/modular-monolith.md   # detailed definitions, TypeScript examples, sources
  README.md
  LICENSE                         # MIT
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as DDD, CQRS, API are fine).

## Plugin contents

### `SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (architecture
  structuring, module boundaries, monolith versus microservices).
- **One-line definition**: a single deployed artifact, strictly bounded
  internal modules, isolated data. Distinct from the big ball of mud (below)
  and microservices (above).
- **The three invariants** (the non-negotiable core):
  1. **Boundary**: each module exposes a public API; everything else is
     internal and unreachable from other modules.
  2. **Communication**: direct call to another module's public API by
     default; in-process events only when decoupling or eventual
     consistency is wanted deliberately.
  3. **Data**: schema per module, no cross-module foreign keys or joins, no
     transaction spanning two modules.
- **Pragmatic guardrails**: coarse modules first, let a module earn its
  independence; match per-module sophistication to need (a CRUD module is
  not a DDD module); a module boundary is a guess, treat it as one.
- **Complementary patterns (references out)**: DDD (where to draw
  boundaries), hexagonal (inside a module), CQRS/ES (optional). None is a
  prerequisite.
- **Adapt to your context** section plus a pointer to the reference.

### `references/modular-monolith.md` (depth, TypeScript examples)

Each section carries TypeScript examples and "when not to apply" notes:

1. **Definition and taxonomy**: single-process / modular / distributed
   monolith (Newman); the symmetry "big ball of mud : monolith ::
   distributed monolith : microservices".
2. **Boundary design**: by business capability (vertical slices), not by
   technical layer; public API versus internal implementation.
3. **Enforcement in TypeScript/Node**: barrel `index.ts` as the public API,
   `@nx/enforce-module-boundaries`, `dependency-cruiser`, pnpm workspace
   packages (`workspace:*`) as the strongest boundary. Correction noted:
   TypeScript project references orchestrate the build, they do not block
   reach-in imports.
4. **Inter-module communication**: direct call versus in-process events,
   with the decision rule.
5. **Data isolation**: schema per module, no cross-module joins or
   transactions.
6. **Trade-offs and when to use**: what a monolith keeps (ACID
   transactions, easier boundary refactoring) versus when microservices are
   justified (Fowler's MicroservicePremium).
7. **Extraction to microservice**: modules as future seams (Strangler Fig).
8. **Anti-patterns**: shared tables across modules, a "common" dumping
   ground, circular dependencies, modules organized by technical layer.

## Research and validation approach

Content must be sourced, not written from memory.

- **Research is done.** A background research pass produced a
  primary-source-cited body of knowledge (Grzybek, Newman, Fowler, Simon
  Brown, Shopify, Spring Modulith). Key corrections already captured:
  `dotnet/eShop` is microservices, not a modular monolith; "big ball of
  mud" is Foote and Yoder (1997); TypeScript project references are build
  orchestration, not encapsulation; Nx does not deprecate barrel files.
- **Validation and review.** After authoring, review the content for
  accuracy against the sources, internal consistency, and adherence to the
  pragmatism and composability framing. The `skill-reviewer` agent can
  assess triggering quality.

## Authoring tools

- `skill-creator` for skill scaffolding and structure best practices.
- `writing-skills` (superpowers), if available, for frontmatter and
  description quality so activation triggers reliably.

## Marketplace integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table.

## Future work (adjacent plugins noted, not designed here)

These surfaced while authoring this plugin and are recorded so the
decomposition is not lost. They are separate topics, not part of the
modular monolith:

- `dependency-injection` (or `dependency-management`): constructor
  injection, inversion of control, poor man's dependency injection versus a
  container, and the composition root (the single place where the object
  graph is wired at application startup). The modular monolith only uses the
  composition root incidentally, to wire module implementations, so the term
  is kept out of this plugin's vocabulary and would belong here instead.

The clean-code batch already recorded `hexagonal-architecture`, `ddd`,
`cqrs`, and `event-sourcing` as future candidates; this plugin references
them as complementary rather than absorbing them.

## Success criteria

- One installable plugin following the existing structure and conventions.
- A lean skill with depth in `references/`.
- Content grounded in researched primary sources and reviewed for accuracy,
  with the known corrections applied.
- Pragmatism and composability framing present, and adjacent patterns
  referenced rather than absorbed.
