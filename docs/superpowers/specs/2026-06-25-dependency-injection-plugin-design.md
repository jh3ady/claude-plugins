# Dependency injection plugin: design

- Date: 2026-06-25
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`,
`modular-monolith`). They share one pattern: a single generic, composable
skill presented as a pragmatic baseline rather than a dogma, with depth
pushed into `references/`.

This work adds one plugin: `dependency-injection`. It was recorded as future
work in the modular monolith design (the composition root surfaced there and
was deliberately kept out, noted as belonging to a future dependency
injection plugin).

The goal is a skill that helps supply an object's dependencies from outside
rather than constructing them internally, applied pragmatically, with Pure DI
(manual wiring) as the default and DI containers treated as an option that
must earn its keep.

## Scope

One independent, a la carte plugin: `dependency-injection`.

### Emphasis (decided): Pure DI first, containers referenced

The core is manual constructor injection (Pure DI), the composition root,
injection styles, object lifetimes, and the anti-pattern catalogue. The
TypeScript DI containers (NestJS, tsyringe, InversifyJS, Awilix) are
presented as an option with their trade-offs and the runtime constraints,
not as a detailed tutorial. This matches the family's pragmatism (a container
must be justified) and the marketplace invariant "one topic = one plugin".

### Boundary (focused, with references out)

Dependency injection proper:

- injection styles (constructor injection as the default; setter/property and
  method injection for specific cases);
- the composition root (a single location, near the entry point, where the
  object graph is composed);
- Pure DI versus a DI container (when a container earns its keep);
- object lifetimes (singleton, transient, scoped) and the captive dependency
  problem;
- the anti-pattern catalogue.

Adjacent concepts are referenced as complementary, never absorbed:

- **DIP (SOLID's D)**: a design principle (depend on abstractions). DI is a
  technique that helps follow DIP; they are distinct. Referenced to
  `solid-principles`, not redefined here.
- **Hexagonal / ports and adapters**: DI is the wiring mechanism that injects
  adapters at the composition root, not the architecture itself.
- **Modular monolith**: uses a single composition root incidentally; each
  module exposes a registration fragment, not its own composition root.

## Key decisions

- **One independent plugin**, installable a la carte.
- **Name: `dependency-injection`** (precise and standard; `dependency-management`
  was rejected as ambiguous with package management).
- **Activation: design-and-review oriented.** The skill activates when wiring
  dependencies, structuring object construction, deciding between manual
  wiring and a DI container, or reviewing for DI anti-patterns, even when the
  term is not used.
- **Lean `SKILL.md`.** The core stays short: the one-line definition, the
  three-way distinction (DI vs IoC vs DIP), the core practices (constructor
  injection default, composition root, Pure DI first, lifetimes), pragmatic
  guardrails, and references-out. Depth, examples, and sources live in
  `references/`.
- **Pragmatism baked in.** Pure DI is the default; a container is justified
  only when convention-based auto-wiring or a large object graph outweighs
  the loss of compile-time safety. Do not inject value objects or entities;
  do not over-abstract with a single-implementation interface that has no
  boundary (ties to the `solid-principles` guardrail).
- **Contested and imprecise points handled honestly:**
  - **Service Locator** is presented even-handedly: Seemann classifies it an
    anti-pattern (hidden dependencies, run-time instead of compile-time
    errors); Fowler treats it as a legitimate DI alternative; the
    disagreement is genuine. The skill states the default position (prefer
    injection, confine any container to the composition root) without
    pretending the matter is settled.
  - **Constructor over-injection** is framed as a code smell (an SRP signal),
    not an anti-pattern, and the fix is to refactor responsibilities (Facade
    or Aggregate Services), not to switch injection styles.
- **Composability.** An "Adapt to your context" section, so users layer their
  own container choice and conventions on top.
- **Examples in TypeScript only.**

## Plugin structure

Mirrors the existing plugins:

```
plugins/dependency-injection/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  skills/dependency-injection/SKILL.md          # lean core
  skills/dependency-injection/references/dependency-injection.md   # detailed definitions, TypeScript examples, sources
  README.md
  LICENSE                         # MIT
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as DI, IoC, DIP, SOLID, API are fine).

## Plugin contents

### `SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (wiring
  dependencies, object construction, manual wiring versus a container, DI
  anti-patterns, even when the term is not used).
- **One-line definition**: an object receives its dependencies from outside
  rather than constructing them itself. A technique, distinct from DIP (a
  principle), IoC (the broad principle), and a container (a tool).
- **The three-way distinction**: DI (technique) vs IoC (broad principle,
  Hollywood principle) vs DIP (SOLID design principle). The most common
  confusion.
- **Core practices**:
  - constructor injection by default (required dependencies present at
    construction);
  - the composition root: one location, near the entry point;
  - Pure DI by default, a container only when it earns its keep;
  - lifetimes (singleton, transient, scoped) and the captive dependency trap.
- **Pragmatic guardrails**: no container on a small app; do not inject value
  objects or entities (injectables versus newables); no service locator
  (default position, noting the debate); constructor over-injection is an SRP
  smell to refactor, not to restyle; a single-implementation interface with
  no boundary is over-abstraction (references the `solid-principles`
  guardrail).
- **Complementary patterns (references out)**: DIP (to `solid-principles`),
  hexagonal (DI wires adapters), modular monolith (one composition root,
  per-module registration fragments). None is redefined here.
- **Adapt to your context** section plus a pointer to the reference.

### `references/dependency-injection.md` (depth, TypeScript examples)

Each section carries TypeScript examples and "when not to apply" notes:

1. **Definition and origin**: Fowler (introduced the term in 2004 by
   consensus, not single-handedly), Seemann and van Deursen. DI as a
   technique to supply dependencies (DI is passing an argument).
2. **DI vs IoC vs DIP**: the precise three-way distinction; the "DI == DIP"
   and "DI == IoC" misconceptions corrected; DIP referenced to
   `solid-principles`.
3. **Injection styles**: constructor injection as the default and why
   (required dependencies guaranteed present); setter/property and method
   injection and when each applies. The two taxonomies (Fowler versus
   Seemann) noted, not merged.
4. **Composition root**: a single location near the entry point; Register
   Resolve Release; confine the container to the composition root; a Pure DI
   wiring example.
5. **Pure DI versus a container**: manual wiring versus auto-wiring; Seemann's
   trade-offs (compile-time safety versus convention-based auto-wiring). TS
   containers (NestJS, tsyringe, InversifyJS, Awilix) referenced with
   trade-offs, plus the runtime constraint (TypeScript types are erased, so
   token-based injection is needed; `reflect-metadata`; legacy
   `experimentalDecorators` versus TC39 Stage 3 decorators).
6. **Object lifetimes**: singleton, transient, scoped; the captive dependency
   problem.
7. **Anti-patterns**: service locator (presented even-handedly, the Seemann
   versus Fowler debate), control freak (newing up dependencies), constrained
   construction, ambient context, injecting the container; constructor
   over-injection framed as a code smell, not an anti-pattern.
8. **Adjacent patterns**: DIP, hexagonal (DI is wiring, not architecture),
   the composition root in a modular monolith (per-module registration
   fragments), Strategy (injecting a strategy is one form of DI; DI is
   broader).

## Research and validation approach

Content must be sourced, not written from memory.

- **Research is done.** A background research pass produced a
  primary-source-cited body of knowledge (Fowler, Seemann and van Deursen,
  Robert C. Martin for DIP, Hevery for injectables versus newables, the
  container docs). Key nuances already captured: the term was introduced by
  consensus; constructor over-injection is a code smell, not an anti-pattern;
  service locator is contested; "Pure DI" replaces "Poor Man's DI"; a module
  exposes a registration fragment, not its own composition root; the two
  injection-style taxonomies must not be merged; TypeScript runtime type
  erasure forces token-based injection.
- **Validation and review.** After authoring, review the content for accuracy
  against the sources, internal consistency, and adherence to the pragmatism
  and composability framing. The `skill-reviewer` agent can assess triggering
  quality.

## Authoring tools

- `skill-creator` for skill scaffolding and structure best practices.
- `writing-skills` (superpowers), if available, for frontmatter and
  description quality so activation triggers reliably.

## Marketplace integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table.

## Success criteria

- One installable plugin following the existing structure and conventions.
- A lean skill with depth in `references/`.
- Content grounded in researched primary sources and reviewed for accuracy,
  with the known nuances and corrections applied.
- Pure DI presented as the default, containers as a justified option.
- Pragmatism and composability framing present, and adjacent patterns
  (DIP, hexagonal, modular monolith) referenced rather than absorbed.
