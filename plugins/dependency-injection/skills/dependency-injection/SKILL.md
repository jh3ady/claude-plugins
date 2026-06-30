---
name: dependency-injection
description: This skill should be used when wiring an object's dependencies, structuring how objects are constructed, choosing between manual wiring and a DI container, or reviewing code for DI anti-patterns, applying dependency injection, even when the term "dependency injection" is not used. Covers constructor injection, the composition root, Pure DI versus containers, object lifetimes, and the anti-pattern catalogue, with TypeScript specifics. Includes pragmatic guardrails against premature containers and over-injection.
---

# Dependency injection

An object receives its dependencies from an external source instead of
constructing them itself. It is a technique, not an architecture, and not the
same as the principle it serves. Apply it pragmatically: Pure DI by default, a
container only when it earns its keep.

## Three things often confused

- **Dependency injection**: the technique of supplying an object's
  dependencies from outside (this skill).
- **Inversion of control (IoC)**: the broad principle that the runtime calls
  your code (the Hollywood principle). DI is one specific style of it.
- **Dependency inversion principle (DIP)**: SOLID's design principle, depend on
  abstractions. DI helps you follow DIP but is not the same thing. See the
  `solid-principles` skill; this skill does not redefine it.

## Core practices

- **Constructor injection by default**: pass required dependencies through the
  constructor, so an object is never half-built. Use setter injection only for
  a genuinely optional dependency, method injection only when it varies per
  call.
- **Composition root**: compose the object graph in one place, as close as
  possible to the entry point. One per application. Confine any container to
  it, and reference it from nowhere else.
- **Pure DI first**: wire the graph by hand. It is strongly typed and fails at
  compile time. Reach for a DI container only when convention-based auto-wiring
  on a large graph outweighs that lost safety.
- **Lifetimes**: singleton, transient, scoped. Watch the captive dependency
  trap: a singleton holding a scoped or transient dependency promotes it and
  breaks under concurrency.

## Guardrails

Prefer the simplest wiring that meets the need:

- Do not reach for a container on a small app. Pure manual wiring is enough
  until the object graph genuinely justifies one.
- Inject services (injectables), not value objects or entities (newables).
- Constructor over-injection is a code smell, not an anti-pattern: too many
  constructor parameters signal an SRP violation. Refactor responsibilities
  (Facade or Aggregate Services); do not switch injection styles to hide it.
- Avoid the service locator and never inject the container itself. (The service
  locator label is debated: Seemann calls it an anti-pattern, Fowler an
  alternative. The safe default is to prefer injection and confine the
  container to the composition root.)
- A single-implementation interface with no boundary is over-abstraction. See
  the `solid-principles` guardrail.

## Complementary patterns (referenced, not redefined)

- **DIP (SOLID)**: the principle DI helps you follow. See `solid-principles`.
- **Hexagonal / ports and adapters**: DI is the wiring that injects adapters at
  the composition root, not the architecture itself.
- **Modular monolith**: one composition root per application; each module
  exposes a registration fragment, not its own root.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top: choose
your container (or none), and define your wiring and lifetime conventions in
your own `CLAUDE.md` or a higher-priority skill, which overrides this baseline.
This skill does not impose them.

## Reference

For the origin, the DI versus IoC versus DIP distinction, injection styles, the
composition root, Pure DI versus containers (with TypeScript token-based
injection and `reflect-metadata`), lifetimes, the anti-pattern catalogue, and
adjacent patterns, all with sources, read `references/dependency-injection.md`.
