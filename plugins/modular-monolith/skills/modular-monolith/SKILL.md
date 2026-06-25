---
name: modular-monolith
description: Apply the modular monolith pattern when structuring, reviewing, or refactoring application architecture, module boundaries, or deployment topology, and when weighing a monolith against microservices, even when the term is not used. Covers public-API module boundaries, inter-module communication, per-module data isolation, TypeScript-ecosystem enforcement, and extraction to microservices. Includes pragmatic guardrails against premature splitting and over-engineering.
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
- **Data**: a schema per module. No shared tables, no cross-module foreign
  keys or joins, no transaction spanning two modules. Cross-module data is
  obtained through the other module's API.

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
  bounded context, but DDD is not required.
- **Hexagonal / ports and adapters**: how to structure a module's inside,
  decided module by module.
- **CQRS and event sourcing**: optional and orthogonal.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:
define your module catalog, naming, and allowed dependencies in your own
`CLAUDE.md` or a higher-priority skill. This skill does not impose them.

## Reference

For the full taxonomy, boundary and enforcement examples in TypeScript, the
communication and data-isolation rules, trade-offs, extraction path, and
anti-patterns, all with sources, read `references/modular-monolith.md`.
