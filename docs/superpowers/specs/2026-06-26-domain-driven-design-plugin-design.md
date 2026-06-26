# Domain-driven design plugin: design

> **Addendum (2026-06-26):** Event sourcing, flagged below as a future plugin,
> has since been realised as the standalone `event-sourcing` plugin. CQRS
> remains a future plugin. The text below is preserved as the point-in-time
> record of the original decision.

- Date: 2026-06-26
- Status: approved (design), pending spec review
- Author: Jean-Denis VIDOT

## Context and goal

The `jh3ady-claude-plugins` marketplace ships a consistent family of
engineering-principle plugins (`commit-conventions`, `review-conventions`,
`solid-principles`, `simplicity-principles`, `clean-code`,
`modular-monolith`, `dependency-injection`, `hexagonal-architecture`). They
share one pattern: a generic, composable skill presented as a pragmatic
baseline rather than a dogma, with depth pushed into `references/` and
adjacent concepts cross-referenced rather than absorbed.

This work adds one plugin: `domain-driven-design`. Domain-driven design is a
larger topic than any existing plugin, so it ships two focused skills under a
single plugin rather than one overloaded skill.

The goal is to help model complex domains the way Eric Evans intended:
isolate the domain, build a ubiquitous language, draw context boundaries, and
model the building blocks, applied pragmatically and matched to the actual
domain complexity, never forced onto simple CRUD.

## Scope

One plugin, `domain-driven-design`, bundling two skills:

- `ddd-strategic-design`: the large-scale modelling decisions (language,
  boundaries, subdomains, context mapping).
- `ddd-tactical-design`: the model building blocks (entities, value objects,
  aggregates, domain events, repositories, domain services, factories,
  modules).

This breaks the family's previous "one plugin = one same-named skill"
invariant on purpose: the topic is too large for a single lean skill, and the
strategic/tactical split is the canonical DDD division. Both skill
descriptions mention "domain-driven design / DDD" so a generic request pulls
the relevant skill (strategic for boundaries, language, and contexts;
tactical for model building blocks). No third umbrella skill: YAGNI.

### Boundary (focused, with references out)

In scope:

- Strategic: ubiquitous language, bounded context, subdomains
  (core/supporting/generic) and the buy-vs-build heuristic, problem space
  versus solution space, context mapping and its relationship patterns.
- Tactical: entity, value object, aggregate and aggregate root, domain event
  (as a DDD building block), repository, domain service, factory, module.

Referenced as complementary, never absorbed:

- **Modular monolith**: module boundaries often align with bounded contexts,
  but a bounded context is a model/language boundary, not a deployment unit.
  Referenced to `modular-monolith`.
- **Hexagonal architecture**: a repository is a secondary port; the
  anti-corruption layer is sketched there already. The application core is
  where the domain model lives. Referenced to `hexagonal-architecture`.
- **Dependency injection, clean code, SOLID**: wiring, naming, and design
  principles the model relies on, referenced to their skills.

Explicitly out of scope, flagged as future plugins:

- **Event storming** (a collaborative modelling workshop technique).
- **CQRS** and **event sourcing**: distinct, often-paired patterns, not DDD
  building blocks. Domain events are covered as a DDD building block; CQRS and
  event sourcing get a cross-reference only.

## Key decisions

- **One plugin, two skills.** `ddd-strategic-design` and `ddd-tactical-design`.
- **Name: `domain-driven-design`** for the plugin; `ddd-` prefixed skill names
  so the strategic/tactical split is explicit and triggers precisely.
- **Activation: design-and-review oriented.** Strategic activates when drawing
  context boundaries, defining a shared language, classifying subdomains, or
  integrating systems/teams. Tactical activates when modelling the building
  blocks, deciding whether something is an entity or a value object, designing
  an aggregate, or reviewing for an anemic domain model, even when the term is
  not used.
- **Lean `SKILL.md` per skill.** Each core stays short: definitions, the core
  practices, pragmatic guardrails, and references-out. Depth, examples, and
  sources live in `references/`.
- **Pragmatism baked in.** Invest deep modelling only in the core domain; buy
  generic subdomains and build supporting ones simply. Full tactical machinery
  (aggregates, value objects, factories) earns its place only when there are
  real invariants or behaviour to protect; for mostly-CRUD slices it is
  over-engineering. Do not model the big ball of mud; wrap it.
- **Misconceptions handled honestly.** The skills correct the common errors
  surfaced in research: one ubiquitous language for the whole organisation
  (false: one per bounded context); one bounded context equals one
  microservice (false: a bounded context is the upper bound, services are a
  finer split); repository equals DAO (false: different abstraction levels);
  one entity equals one aggregate equals one repository (false: repositories
  exist only for aggregate roots); the anemic domain model framed as a
  legitimate style (it is an anti-pattern, per Fowler).
- **Composability.** An "Adapt to your context" section in each skill, so
  users layer their own folder layout, naming, and which slices justify full
  DDD on top.
- **Examples in TypeScript only.**

## Plugin structure

Mirrors the existing plugins, with two skills:

```
plugins/domain-driven-design/
  .claude-plugin/plugin.json      # name, version 0.1.0, author, MIT license, homepage, keywords
  README.md                       # covers both skills
  LICENSE                         # MIT
  skills/
    ddd-strategic-design/
      SKILL.md                    # lean core
      references/ddd-strategic-design.md   # detailed definitions, TypeScript examples, sources
    ddd-tactical-design/
      SKILL.md                    # lean core
      references/ddd-tactical-design.md    # detailed definitions, TypeScript examples, sources
```

Writing conventions for all generated files: English, no em-dashes, words
written in full (standard acronyms such as DDD, CQRS, ACL, OHS, API are fine).

## Plugin contents

### `ddd-strategic-design/SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (context
  boundaries, shared language, subdomain classification, system/team
  integration, even when the term is not used).
- **Ubiquitous language**: a living, rigorous language co-owned by domain
  experts and developers, reflected in code and tests; one per bounded
  context, not a one-off glossary.
- **Bounded context**: an explicit model and language boundary within which
  one model is consistent; one-to-one with the ubiquitous language.
- **Subdomains**: core (complex, competitive advantage, build in-house),
  supporting (simple, necessary, build simply or outsource), generic (complex
  but solved, buy off-the-shelf); the buy-vs-build heuristic; problem space
  (subdomain) versus solution space (bounded context).
- **Context mapping**: the context map and the relationship patterns
  (Partnership, Shared Kernel, Customer/Supplier, Conformist, Anticorruption
  Layer, Open Host Service, Published Language, Separate Ways, Big Ball of
  Mud), grouped upstream/downstream.
- **Pragmatic guardrails**: invest deep modelling in the core only; do not
  model the big ball of mud (wrap it); CRUD is over-engineering; a bounded
  context is not a microservice (referenced to `modular-monolith`).
- **References out**: `modular-monolith` (module boundaries),
  `hexagonal-architecture` (anti-corruption layer, application core); future
  plugins (event storming, CQRS, event sourcing) flagged out of scope.
- **Adapt to your context** section plus a pointer to the reference.

### `ddd-tactical-design/SKILL.md` (lean core)

- Frontmatter: `name` plus a trigger-oriented `description` (modelling
  building blocks, entity versus value object, aggregate design, anemic
  domain model review, even when the term is not used).
- **Entity**: identity-based equality, continuity through time.
- **Value object**: equality by value, immutability, side-effect-free.
- **Aggregate and aggregate root**: the consistency and transaction boundary;
  Vernon's four rules (model true invariants in the boundary, design small
  aggregates, reference other aggregates by identity, use eventual consistency
  outside the boundary).
- **Domain event**: a DDD building block representing something that happened
  that domain experts care about; CQRS and event sourcing are separate
  patterns, out of scope.
- **Repository**: a collection-like abstraction over aggregate persistence,
  one per aggregate root; not a DAO; distinct from a factory.
- **Domain service**: domain logic that belongs to no single entity or value
  object; distinct from an application service (orchestration, no business
  rules).
- **Factory**: encapsulates valid construction of a complex object or
  aggregate; not needed where a constructor suffices (YAGNI).
- **Module**: a named, cohesive partition of the model.
- **Pragmatic guardrails**: the anemic domain model is an anti-pattern; prefer
  small aggregates; not every entity is an aggregate root or needs a
  repository; CRUD is over-engineering.
- **References out**: `hexagonal-architecture` (a repository is a secondary
  port; the core holds the model), `dependency-injection`, `clean-code`,
  `solid-principles`.
- **Adapt to your context** section plus a pointer to the reference.

### `references/*.md` (depth, TypeScript examples, sources)

Each reference carries TypeScript examples and "when not to apply" notes,
sourced like `hexagonal-architecture` (attributed quotations).

## Research and validation approach

Content must be sourced, not written from memory.

- **Research is done.** Two background research passes produced
  primary-source-cited bodies of knowledge for strategic and tactical design
  (Evans' Blue Book and the 2015 DDD Reference, Vernon's *Implementing
  Domain-Driven Design* and *Effective Aggregate Design*, Fowler's bliki,
  Khononov's *Learning Domain-Driven Design*). Key nuances and misconceptions
  already captured (see Key decisions). Sourcing caveat: do not publish
  unverified verbatim Evans quotations; use the verified Fowler and Vernon
  quotations as-is, and attribute Evans paraphrases to "Evans, DDD (2003)" or
  "DDD Reference (2015)" without invented page numbers. Note Partnership and
  Big Ball of Mud as 2015 DDD Reference additions.
- **Validation and review.** After authoring, review the content for accuracy
  against the sources, internal consistency, and adherence to the pragmatism
  and composability framing. The `skill-reviewer` agent can assess triggering
  quality for both skills.

## Authoring tools

- `skill-creator` for skill scaffolding and structure best practices.
- `writing-skills` (superpowers), if available, for frontmatter and
  description quality so activation triggers reliably.

## Marketplace and settings integration

- Add one entry to `.claude-plugin/marketplace.json` (name, source,
  description, version `0.1.0`).
- Add one row to the root `README.md` plugins table (if present).
- Enable the plugin in `~/.claude/settings.json` (symlinked to
  `~/.config/claude-config/claude/settings.json`): add
  `"domain-driven-design@jh3ady-claude-plugins": true` to `enabledPlugins`.

## Success criteria

- One installable plugin following the existing structure and conventions,
  bundling two focused skills.
- Lean skills with depth in `references/`.
- Content grounded in researched primary sources and reviewed for accuracy,
  with the known nuances and corrections applied.
- Pragmatism and composability framing present; adjacent patterns (modular
  monolith, hexagonal, dependency injection, SOLID, clean code) referenced
  rather than absorbed; event storming, CQRS, and event sourcing flagged as
  future work.
- Registered in the marketplace and enabled in settings.
