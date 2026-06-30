---
name: modular-monolith
description: This skill should be used when structuring, reviewing, or refactoring application architecture, module or package structure, or deployment topology, and when weighing a monolith against microservices or asking whether to split a system into services, even when the term "modular monolith" is not used, applying the modular monolith pattern. Covers public-API module boundaries, inter-module communication, per-module data isolation, TypeScript-ecosystem enforcement, and extraction to microservices. Includes pragmatic guardrails against premature splitting and over-engineering.
---

# Modular monolith

One application deployed as a single artifact, internally split into modules
with strictly enforced boundaries. It is the disciplined monolith: above the
big ball of mud (no boundaries), below microservices (no network premium).
Apply it as a pragmatic default, not a dogma.

## The three invariants

- **Boundary**: each module exposes a public API; everything else is internal
  and unreachable from other modules. Define modules by business capability
  (vertical slice), not by technical layer.
- **Communication**: call another module's public API directly by default.
  Reach for an in-process event only when you deliberately want decoupling or
  eventual consistency. Never reach into another module's internals.
- **Data**: each module owns its data; no other module reads or writes it
  except through that module's public API. No cross-module foreign keys,
  joins, or transactions. Schema-per-module is the canonical enforcement (a
  separate database is stronger; table ownership by convention is the legacy
  fallback). The invariant is logical ownership, not the storage mechanism.

## Enforcement (TypeScript/Node)

TypeScript has no cross-file `internal`, so boundaries are tooling-enforced,
weakest to strongest: a barrel `index.ts` as the only public entry point;
lint rules (`@nx/enforce-module-boundaries`, `dependency-cruiser`); separate
pnpm workspace packages (`workspace:*`), the strongest boundary. Note:
TypeScript project references orchestrate the build, they do not block
reach-in imports.

## Guardrails

Prefer the simplest structure that meets the need:

- Start with fewer, coarser modules; let a module earn its independence.
  Splitting later is cheap, merging back is costly. A module boundary is a
  guess, treat it as one.
- Match per-module sophistication to need: a CRUD module is not a DDD module.
- Do not make everything event-driven in-process; that is hidden coupling in
  disguise. A direct call is the default.
- A modular monolith is the sensible default. Move to microservices only for
  a real driver: independent scaling, deploy cadence, team autonomy, or
  polyglot needs, not for fashion.

## Complementary patterns (not prerequisites)

The modular monolith is the container. These are choices about each module's
content, referenced here, not imposed:

- **DDD bounded contexts**: where to draw boundaries. A module can be a
  bounded context, but DDD is not required. See the `ddd-strategic-design` skill for bounded contexts and context mapping.
- **Hexagonal / ports and adapters**: how to structure a module's inside,
  decided module by module.
- **Event sourcing and CQRS**: optional and orthogonal. See the `event-sourcing`
  and `cqrs` skills; the two are frequent, separate companions.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:
define your module catalog, naming, allowed dependencies, and data-ownership
model (a multi-tenant tenancy axis or a legacy storage scheme, for example) in
your own `CLAUDE.md` or a higher-priority skill, which overrides this baseline.
This skill does not impose them.

## Reference

For the full taxonomy, boundary and enforcement examples in TypeScript, the
communication and data-isolation rules, trade-offs, extraction path, and
anti-patterns, all with sources, read `references/modular-monolith.md`.
