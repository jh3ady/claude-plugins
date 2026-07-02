---
name: hexagonal-architecture
description: This skill should be used when structuring, reviewing, or refactoring how an application's business logic is isolated from its infrastructure (web frameworks, databases, message brokers, external APIs, the UI), when deciding where a use case, a repository interface, a controller, an ORM, or an HTTP client belongs, when a domain is leaking framework or persistence details, or when asking how to test business logic without a database, even when the terms "hexagonal", "ports and adapters", "onion", or "clean architecture" are not used, applying hexagonal architecture (ports and adapters). Covers the dependency rule, primary (driving) and secondary (driven) ports and adapters, the application core, composition-root wiring, the relationship to Onion and Clean Architecture, and TypeScript modelling. Includes pragmatic guardrails against over-porting, mapping fatigue, and applying it to simple CRUD.
---

# Hexagonal architecture (ports and adapters)

An application core that is isolated from the outside world by ports
(interfaces it owns) and reached only through adapters (concrete
implementations of those ports). Alistair Cockburn's stated intent: "Allow an
application to equally be driven by users, programs, automated test or batch
scripts, and to be developed and tested in isolation from its eventual run-time
devices and databases." Apply it pragmatically, not as a blanket mandate.

The name is just a drawing convention: "The hexagon is not a hexagon because
the number six is important, but rather to allow the people doing the drawing
to have room to insert ports and adapters as they need." There is no
significance to six sides.

## The one rule

Dependencies point inward. The core depends on nothing outside itself; the
outside depends on the core. "The rule to obey is that code pertaining to the
inside part should not leak into the outside part." This is the dependency
inversion principle applied at the architecture scale: the core defines an
interface (a port), and infrastructure implements it, so the arrow that would
naturally point from core to database is inverted. See the
`dependency-injection` and `solid-principles` skills; this skill does not
redefine them.

## Ports and adapters

- **Port**: an interface the core owns, named for a purpose, not a technology.
  "The protocol for a port is given by the purpose of the conversation."
- **Primary (driving) port**: what the core exposes so actors can drive it,
  typically a use case. The driving adapter (HTTP controller, CLI, test) calls
  it.
- **Secondary (driven) port**: what the core requires from the outside,
  typically a repository or a gateway interface. The driven adapter (ORM
  repository, HTTP client, message publisher) implements it.
- **Adapter**: "For each external device there is an adapter that converts the
  API definition to the signals needed by that device and vice versa." All
  framework, ORM, and transport concerns live here, never in the core.

A driving adapter calls a port; a driven adapter implements a port. Keep the
distinction straight and the dependency direction follows automatically.

The adapter here is the Adapter design pattern applied at the architectural
boundary: the generic mechanism, wrapping an incompatible interface so it fits
the one the core expects, is covered by the `design-patterns` skill, while this
skill governs its driving and driven roles around the core.

When a secondary port integrates a foreign model (an external system, a legacy
system, or another bounded context), translate that model into the domain's
terms at the boundary so it never leaks past the port. This is where a
Domain-Driven Design anti-corruption layer comes into play. The two are not
synonyms, though: an adapter over your own model is a technology boundary, not
an anti-corruption layer, and the pattern's full treatment is DDD territory, covered by the `ddd-strategic-design` skill, not this one.

## Wiring and testing

- **Composition root**: concrete adapters are chosen and injected into the core
  in one place at startup, never imported by the core. This is dependency
  injection as the mechanism; hexagonal decides what gets injected (ports).
- **Testing in isolation**: because the core depends only on ports, substitute
  an in-memory adapter for the real one and test business logic with no
  database or network. This is the original motivation, not a side effect.
- **`testing-strategy`**: integration tests exercise a real adapter against real
  infrastructure; the ports defined here are the seams those tests cross.
  `testing-strategy` decides how many such tests to keep relative to unit and
  end-to-end tests.

## Guardrails

Match the sophistication to the actual need:

- A port earns its place when a second adapter is plausible (a real database
  plus an in-memory test double already counts). A port with exactly one
  adapter and no second on the horizon is ceremony, not flexibility.
- Watch mapping fatigue: domain model, persistence model, and DTO with mappers
  between them multiply the code for every field. On a CRUD slice that is pure
  cost. Keep the layers you can justify.
- Never leak ORM entities, framework request objects, or transport types into
  the core; that quietly reverses the one rule. Map at the adapter boundary.
- Do not put business logic in adapters, and do not let use cases call use
  cases into a tangle. The core holds the logic; adapters translate.
- The choice is a gradient, not all-or-nothing. The one rule is cheap and hard
  to retrofit; the apparatus (the ports and mapping layers above) is what costs.
  For a thin CRUD slice or a junior team where onboarding dominates, a plain
  layered structure is often right. When you suspect a real domain but have not
  discovered it yet (an early MVP), hold the one rule from day one to keep the
  option open, and defer the apparatus until the domain takes shape, growing it
  slice by slice.

## Relationship to Onion and Clean Architecture

Onion (Palermo) and Clean (Martin) are the same core idea in different
vocabularies: isolate the domain, point all dependencies inward. Martin states
they "are very similar" and "all have the same objective". Onion adds concentric
DDD layers; Clean adds a named Dependency Rule and a four-ring model. Treat a
request framed in any of these terms as the same problem this skill addresses.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: your
port naming, folder layout, mapping strategy, and which slices justify the full
hexagon versus a plain layered design. Declare those in your own `CLAUDE.md` or
a higher-priority skill, which overrides this baseline. This skill does not
impose them.

## Reference

For the canonical definitions with sources, the dependency rule, detailed port
and adapter modelling, the adapter and anti-corruption-layer relationship,
composition-root wiring, testing, the Onion and Clean comparison, the
anti-pattern catalogue, and the pragmatic when-not-to-use analysis, all with
TypeScript examples, read `references/hexagonal-architecture.md`.
