---
name: screaming-architecture
description: This skill should be used when judging whether a codebase's top-level layout makes its business domain legible at a glance rather than merely announcing its framework, when a newcomer cannot tell what a system does from its directory tree, when choosing between organising code by technical layer (controllers, services, repositories) and organising it by feature, use case, or business capability, or when reviewing a folder or project structure for what it reveals about the domain, even when the term "screaming architecture" is not used, applying Screaming Architecture. It covers Robert C. Martin's thesis that an architecture should scream its use cases not its frameworks, the building-blueprint analogy, the web and the database as delivery details, package-by-feature versus package-by-layer, vertical slices, and concrete folder-tree examples. Make sure to consult this skill whenever someone talks about folder structure, project layout, package-by-feature, organising code by feature versus by layer, vertical slices, or whether a repository structure reveals what the system does. This is the legibility and communication heuristic: for the direction of dependencies reach for hexagonal or clean architecture, and for module boundary enforcement reach for the modular monolith. Includes pragmatic guardrails against over-fragmenting small CRUD projects into single-file feature folders and against treating it as a dependency rule rather than a communication heuristic.
---

# Screaming Architecture

A codebase whose top-level structure announces what the system does, not which
framework it is built with. Robert C. Martin's test, from the 2011 essay that
named the idea: "When you look at the top level directory structure, and the
source files in the highest level package; do they scream: Health Care System,
or Accounting System, or Inventory Management System? Or do they scream: Rails,
or Spring/Hibernate, or ASP?" A good architecture screams the first kind of
answer.

The analogy is a building's blueprints. Looking at the plans for a library you
see the entrance, the reading rooms, the small offices, and shelf upon shelf of
book stacks; the drawing screams "Library". Martin's claim is that the plans of
a software system should scream its use cases the same way, because "software
architectures are structures that support the use cases of the system."

This is a heuristic about communication, not a dependency rule. It tells you
what the structure should reveal; it does not by itself say which way
dependencies point. Pair it with `hexagonal-architecture` or clean architecture
for the dependency direction. Apply it pragmatically, not as a blanket mandate.

## Frameworks are details, not the architecture

Martin's sharpest point is that frameworks must not own the shape of a system:
"Architectures are not (or should not) be about frameworks. Architectures should
not be supplied by frameworks. Frameworks are tools to be used, not
architectures to be conformed to." A top-level structure of `controllers/`,
`services/`, `repositories/`, `models/` screams the framework's MVC convention.
It tells a newcomer how the code is wired, but nothing about what business it
serves.

The same reasoning demotes delivery and persistence to details. "The Web is a
delivery mechanism... The fact that your application is delivered over the web
is a detail" and should not dominate the structure. A database is likewise a
detail: the use cases do not care whether records live in PostgreSQL or in flat
files. The structure should foreground the domain and push these choices to the
edges.

## The testability corollary

A structure that screams its use cases is also one you can test without standing
up the machinery. Martin: "you should be able to unit-test all those use cases
without any of the frameworks in place... Your business objects should be plain
old objects." If exercising a use case requires a web server, a live database,
and the framework's container, the framework has taken over the architecture.
Testability in isolation is the practical signal that the domain, not the
tooling, sits at the centre. This is the same isolation goal as
`hexagonal-architecture`.

## Package by feature, not by layer

The concrete move is to organise the top level around business capabilities and
use cases rather than technical roles. This is the well-known choice between
package-by-layer and package-by-feature.

Package by layer (screams the stack):

```
src/
  controllers/
  services/
  repositories/
  models/
```

Code for one capability is scattered across every folder, cohesion within a
folder is low, coupling between folders is high, and the layout says nothing
about the domain.

Package by feature (screams the domain):

```
src/
  bookings/
  apartments/
  payments/
  invoicing/
```

Everything a capability needs sits together; a newcomer reads the domain
straight off the tree. Cohesion is high within a feature and coupling is low
between features, which is exactly the property a modular monolith depends on
(see `modular-monolith`).

You can go a level finer and name use cases, so the structure reads as a list of
the things the system actually does:

```
src/
  bookings/
    cancel-booking/
    confirm-booking/
  payments/
    capture-payment/
    refund-payment/
```

This is the same instinct behind vertical slice architecture: "Minimize coupling
between slices, and maximize coupling in a slice" (Jimmy Bogard). Each slice
holds everything one request needs, from the entry point down to data access.

## It composes with layered architectures rather than replacing them

Screaming Architecture and clean or hexagonal architecture answer different
questions. One asks what the structure communicates; the other asks which way
dependencies point. They combine: scream the domain at the top, then layer
within each feature.

```
modules/
  ticketing/
    application/      # use cases for ticketing
    domain/           # entities, value objects, rules
    infrastructure/   # adapters: persistence, messaging
  payments/
    application/
    domain/
    infrastructure/
```

The first thing you read is the business (ticketing, payments); the layers live
one level down, inside each capability. Whether to carry full layers inside
every feature is itself a pragmatic call (see the guardrails); the screaming
part is that the top level names the domain, not the stack.

## Relationship to domain-driven design

Screaming Architecture is the structural echo of the ubiquitous language. When
the top-level folders and modules carry the same names the domain experts use,
the code speaks the business's language back to it (see `ddd-strategic-design`
in the `domain-driven-design` plugin). Top-level modules often line up with
bounded contexts or subdomains, and use-case folders with the commands and
aggregates inside them (see `ddd-tactical-design`, same plugin). If your
structure needs a glossary to map folder names to business concepts, it is not
screaming.

## Guardrails

- **Do not over-fragment a small or CRUD-heavy project.** A feature folder
  holding a single file, repeated across a dozen near-identical capabilities, is
  noise, not intent. The benefit of a screaming structure scales with the size
  and richness of the domain; on a thin CRUD slice a flat or lightly grouped
  layout is clearer. Apply the rule of three (see `simplicity-principles`)
  before carving out a slice.
- **It is a communication heuristic, not the dependency rule.** Naming a folder
  for the domain does not make dependencies point inward. Use
  `hexagonal-architecture` or clean architecture for that; use this skill for
  what the names reveal. Confusing the two yields domain-named folders that still
  leak framework and persistence concerns.
- **Frameworks are still used, not banished.** The point is that the framework
  should not dictate the top-level shape or seep into the core, not that you
  write everything from scratch. View each framework "with a jaded eye" (Martin)
  and keep it at the edges.
- **Shared and technical folders are allowed, kept subordinate.** Real systems
  need somewhere for genuinely cross-cutting code (a shared kernel,
  infrastructure, configuration). That is fine as long as the business
  capabilities dominate the top level. A structure that is mostly `shared/` and
  `common/` has stopped screaming.
- **Do not rename without reorganising.** Relabelling `services/` to
  `domain-services/` changes nothing. Screaming Architecture is about where code
  lives and how cohesive each grouping is, not about cosmetic names.

## Adapt to your context

This skill stays generic on purpose. The right granularity (capabilities,
features, or individual use cases), whether each feature carries full layers,
where shared code lives, and your naming conventions are yours to set. Declare
them in your own `CLAUDE.md` or a higher-priority skill, which overrides this
baseline. This skill does not impose a folder layout; it gives you the test to
judge one: does it scream the domain, or the framework?

## Reference

For the canonical essay with its quotes and sources, the building-blueprint
analogy in full, the package-by-feature versus package-by-layer history and
Simon Brown's package-by-component, vertical slice architecture, the composition
with hexagonal, clean, and onion architecture, the relationship to
domain-driven design and the modular monolith, worked folder-tree examples
across back-end and front-end stacks, and the full when-not-to-use analysis,
read `references/screaming-architecture.md`.
