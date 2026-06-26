# CQRS plugin: design

- Date: 2026-06-26
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle and architecture plugins (`commit-conventions`,
`review-conventions`, `solid-principles`, `simplicity-principles`,
`clean-code`, `modular-monolith`, `dependency-injection`,
`hexagonal-architecture`, `domain-driven-design`, `event-sourcing`). They
share one pattern: a single generic, composable skill presented as a
pragmatic baseline rather than a dogma, with depth pushed into `references/`.

This work adds one plugin: `cqrs` (Command Query Responsibility Segregation).
It is the natural sibling of `event-sourcing`, which already cross-references
CQRS. The marketplace invariant "one architecture pattern = one mono-skill
plugin" (followed by `hexagonal-architecture`, `modular-monolith`,
`dependency-injection`, `event-sourcing`) applies directly. CQRS is not
folded into `domain-driven-design` (CQRS is not strictly DDD) nor into
`event-sourcing` (CQRS is used very often without event sourcing, and merging
would blur that boundary).

The goal is a skill that helps separate a write model from a read model,
applied pragmatically, with strong guardrails against the dominant failure
mode: applying CQRS to simple CRUD or treating it as a top-level architecture.

## Scope

One independent, a la carte plugin: `cqrs`.

### Emphasis (decided): core pattern plus guardrails

The core is the command/query distinction promoted to the model level,
command and query handlers, the write model versus read models and
projections, the levels of separation, and the consistency question. The
guardrails against over-application are first-class, surfaced in the
description itself, because CQRS is one of the most over-applied patterns.

The wider machinery (command and query buses, mediator, message brokers,
sagas) is deliberately out of scope and referenced as adjacent, not absorbed.
Read models and projections are covered at the level CQRS needs; the deeper
projection and eventual-consistency treatment lives in `event-sourcing`.

### Boundary (focused, with references out)

CQRS proper:

- the command/query distinction at the model level, and how it differs from
  Meyer's Command Query Separation (CQS, at the method level);
- commands (mutate state, return no data, named by business intent) versus
  queries (return DTOs, never mutate, no domain logic);
- the building blocks: command handlers, query handlers, the write model
  (aggregates plus repository), read models and projections;
- the levels of separation (shared store to separate stores);
- consistency (when eventual consistency does and does not arise);
- the guardrails: when not to use CQRS, and CQRS as a tactical pattern scoped
  to a bounded context rather than a system-wide architecture.

Adjacent concepts are referenced as complementary, never absorbed:

- **Event sourcing**: independent from CQRS in one direction only. CQRS does
  not require event sourcing; event sourcing effectively implies CQRS (the
  event store is the write model, projections are the read model). Referenced
  to `event-sourcing`, not redefined here.
- **DDD aggregates**: the write model typically guards consistency through
  aggregates. Referenced to `domain-driven-design`.
- **Hexagonal architecture**: a common wiring convention for CQRS (handlers as
  primary ports, repositories and read stores as secondary adapters), but no
  primary source ties the two. Presented as an architectural choice, not
  doctrine. Referenced to `hexagonal-architecture`.
- **Command and query buses, mediator, message brokers, sagas**: optional
  delivery and scaling machinery, not part of the core pattern. Mentioned as
  adjacent, not detailed.

## Key decisions

- **One independent plugin**, installable a la carte.
- **Name: `cqrs`** (the standard acronym; unambiguous).
- **Activation: design-and-review oriented.** The skill activates when
  separating a write model from a read model, designing command and query
  handlers, deciding whether read and write paths should diverge, or reviewing
  a system that splits reads from writes, even when the term "CQRS" is not
  used.
- **Lean `SKILL.md`.** The core stays short: the minimal definition, the
  CQS-versus-CQRS distinction, command versus query, the building blocks, the
  levels of separation, the consistency rule, pragmatic guardrails, and
  references-out. Depth, examples, and sources live in `references/`.
- **Pragmatism baked in.** The default position is: do not reach for CQRS on a
  CRUD domain; scope it to a single bounded context; do not equate CQRS with
  "two databases plus a message bus plus event sourcing". The minimal,
  single-store form is the foundational level.
- **Sourced nuances handled honestly** (verified against primary sources):
  - **CQRS derives from CQS but is distinct.** CQS (Meyer) is method-level;
    CQRS (named by Greg Young) promotes the same distinction to the object or
    model level. Young's minimal framing: "the creation of two objects where
    there was previously only one".
  - **CQRS is not an architecture.** Young: a "small tactical pattern", "not a
    top level architecture", describing "something inside a single system or
    component". Fowler: use it "only on specific portions of a system (a
    BoundedContext)" and "be very cautious".
  - **The core does not require separate stores, eventual consistency, or a
    message bus.** Microsoft CQRS Journey: applying CQRS "does not mandate that
    you split the data store". Young: "CQRS does not require a message bus".
  - **Eventual consistency is a consequence of a separate or asynchronous read
    store, not of CQRS itself.** With a shared store the read side can be
    strongly consistent.
  - **The "levels" framing is partly informal.** The two-level version
    (separate models in a single data store as the foundational level;
    separate models in different data stores as the advanced level) is from a
    primary source (Microsoft Azure pattern guidance). The finer community
    ladder is informal and will be flagged as such.
  - **The hexagonal pairing is convention, not doctrine.** No primary source
    among Young, Fowler, Dahan, or the Microsoft guidance links CQRS to
    hexagonal architecture; it is presented as the author's wiring choice.
  - **ES-implies-CQRS asymmetry.** Stated explicitly to avoid the common
    oversimplification that the two patterns are fully independent in both
    directions.
- **Composability.** An "Adapt to your context" section, so users layer their
  own bus, framework, and storage choices on top.
- **Examples in TypeScript only.** Consistent with `dependency-injection`,
  `modular-monolith`, and `hexagonal-architecture`.

## Plugin structure

Mirrors the existing plugins:

```
plugins/cqrs/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  skills/cqrs/SKILL.md            # lean core
  skills/cqrs/references/cqrs.md  # detailed definitions, TypeScript examples, sources
  README.md
  LICENSE                         # MIT
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as CQRS, CQS, DDD, ES, DTO, API are
fine).

## Plugin contents

### `SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (separating a
  write model from a read model, command and query handlers, deciding whether
  read and write paths diverge, reviewing a reads-from-writes split, even when
  the term is not used; with the guardrail angle surfaced).
- **Minimal definition**: the command/query distinction promoted to the model
  level; "two objects where there was one" (Young). CQS (method-level, Meyer)
  versus CQRS (model-level).
- **Command versus query**: command mutates state, returns no data, named by
  business intent (`BookHotelRoom`, not `setStatus`); query returns DTOs,
  never mutates, carries no domain logic.
- **The building blocks**: command handlers, query handlers, the write model
  (aggregates plus repository), read models and projections. Short TypeScript
  interfaces (`Command`, `CommandHandler<T>`, a query returning a read DTO).
- **The levels of separation**: separate models on a shared store (the
  foundational level) then separate stores (the advanced level); the finer
  ladder flagged as informal.
- **Consistency**: eventual consistency is not a consequence of CQRS; it
  arises only when the read store is separate or asynchronous. A shared store
  allows a strongly consistent read side.
- **Pragmatic guardrails (when not to use)**: simple CRUD and domains without
  rich business rules; CQRS is a tactical pattern scoped to a bounded context,
  not a system-wide architecture; do not conflate CQRS with "two databases
  plus a message bus plus event sourcing".
- **Complementary patterns (references out)**: event sourcing (the
  asymmetry), DDD aggregates (the write model), hexagonal (a wiring
  convention, not doctrine), and command/query buses and mediators (adjacent
  delivery machinery, not the core). None is redefined here.
- **Adapt to your context** section plus a pointer to the reference.

### `references/cqrs.md` (depth, TypeScript examples)

Each section carries TypeScript examples and "when not to apply" notes:

1. **Definition and origin**: Meyer's CQS, Young naming CQRS, Fowler's
   write-up. The method-level versus model-level distinction; Young's "two
   objects where there was one" minimal definition.
2. **Commands and queries**: intent-revealing, task-based commands; queries
   returning DTOs or projections with no domain logic; the task-based UI angle
   (Dahan).
3. **Building blocks**: command handlers, query handlers, the write model
   (aggregates plus repository), read models and projections, with a worked
   TypeScript example (a command path and a query path side by side).
4. **Levels of separation**: shared store (foundational) and separate stores
   (advanced) from the Microsoft guidance; the finer community ladder noted as
   informal; the trade-offs of each.
5. **Consistency**: strong consistency on a shared store; eventual consistency
   only when the read store is separate or asynchronous; how the read side is
   kept up to date (synchronous update versus event-driven projection),
   referencing `event-sourcing` for the deep treatment.
6. **When not to use CQRS**: CRUD and simple domains; the over-application
   failure modes (reaching for separate stores, messaging, or event sourcing
   when only a code-level read/write split was needed); CQRS scoped to a
   bounded context, not the whole system.
7. **Relationship to adjacent patterns**: event sourcing (the asymmetry: CQRS
   without ES yes, ES without CQRS not really), DDD aggregates (the write
   model), hexagonal (handlers as primary ports, repositories and read stores
   as secondary adapters, presented as convention), and command/query buses
   and mediators (optional delivery machinery).
8. **Sources**: Greg Young (the 2010 and 2012 posts, "CQRS is not an
   Architecture"), Martin Fowler (`bliki/CQRS.html`), Udi Dahan ("Clarified
   CQRS"), Microsoft (the Azure CQRS pattern page and the CQRS Journey
   reference), with the sourcing caveats recorded below.

## Research and validation approach

Content must be sourced, not written from memory.

- **Research is done.** A research pass produced a primary-source-cited body
  of knowledge (Young, Fowler, Dahan, the Microsoft CQRS Journey and Azure
  pattern guidance). Key nuances already captured and verified: the CQS to
  CQRS promotion from method to model level; "two objects where there was
  one"; CQRS as a small tactical pattern, not an architecture; the core does
  not require separate stores, eventual consistency, or a message bus;
  eventual consistency follows from a separate or asynchronous read store, not
  from CQRS itself; the two-level separation framing is sourced while the finer
  ladder is informal; the hexagonal pairing is convention, not doctrine; and
  the ES-implies-CQRS asymmetry.
- **Sourcing caveats recorded during research:** Young's canonical "CQRS
  Documents" PDF would not parse and was corroborated through the Microsoft
  CQRS Journey reference that quotes it; the cqrs.nu / Kalele FAQ pages
  returned 404 and were not relied upon (re-check before citing); the Udi
  Dahan extraction is a paraphrase summary, so verify exact wording before any
  verbatim quote.
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
- Add the CQRS cross-reference from `event-sourcing` (and optionally
  `domain-driven-design`) once the plugin exists, mirroring how the existing
  architecture plugins cross-reference each other.

## Success criteria

- One installable plugin following the existing structure and conventions.
- A lean skill with depth in `references/`.
- Content grounded in researched primary sources and reviewed for accuracy,
  with the known nuances and corrections applied (the CQS-to-CQRS promotion,
  CQRS as a tactical pattern not an architecture, the no-separate-store and
  no-message-bus minimum, the consistency rule, the sourced-versus-informal
  levels framing, the convention status of the hexagonal pairing, and the
  ES-implies-CQRS asymmetry).
- Pragmatism and composability framing present, with the guardrails against
  over-application surfaced in the description.
- Adjacent patterns (event sourcing, DDD aggregates, hexagonal, buses and
  mediators) referenced rather than absorbed.
