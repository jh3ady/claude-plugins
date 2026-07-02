---
name: design-patterns
description:
  This skill should be used when introducing, reviewing, or refactoring around a point of variation; hesitating between two patterns; asking whether a pattern is warranted here; or recognising a smell whose named resolution is a design pattern (behaviour that varies at runtime, repeated null guards, families of related objects, a tangle of conditionals), or when a named design pattern needs to be applied or implemented, even when no pattern is named. It covers design patterns, the Gang of Four catalogue, and modern idioms (Null Object, Result/Either, Specification), with judgement on when to reach for a pattern and when to refuse it. Includes explicit guardrails against speculative application:
    a pattern you cannot name a current need for is speculative abstraction, not good design. Routes specialised applications to the owning architecture plugins: boundary adapters belong to hexagonal-architecture, the CQRS command message belongs to cqrs, the aggregate factory belongs to domain-driven-design, and dependency injection wiring belongs to dependency-injection.
---

# Design patterns

A design pattern is a named, reusable solution to a recurring design problem; the Gang of Four (Gamma et al., 1994)
groups them into creational, structural, and behavioral.

## The decision reflex

A pattern answers an identified variation point, not an anticipated one. Before reaching for one, name the concrete
problem: what varies today, what is duplicated today, what is rigid to change today. If the answer is "it might vary
later", that is speculation, not a reason to abstract.

The rule of three is the practical gate: wait until the third case before generalising. The first case is a one-off. The
second case suggests a coincidence. The third case reveals a pattern worth naming and extracting. Introducing the
abstraction at the first case is premature; it pays the cost of indirection before any benefit exists.

## Pragmatic, not anti-extensible

Pragmatism is not hostility to abstraction. When a variation point is real and identified, opening it cleanly with the
right pattern is the Open/Closed Principle done right, not over-engineering. A system designed to accept a new payment
provider without touching existing payment logic, or a notification strategy that adds a new channel without touching
the dispatch logic, is well-designed. The fault is speculative abstraction, where the variation point is anticipated but
does not yet exist. The right question is always: is this variation point real and present, or is it imagined?

## Reach for the minimal form

In TypeScript, first-class functions and closures often replace a multi-class pattern. A Strategy is frequently a
function parameter; a Command is often a closure that captures its context; a Decorator is frequently a wrapping
function. The class hierarchy pays off when the pattern needs to carry state across calls, when the type system needs to
express the contract explicitly, or when the same interface is implemented by many collaborators. Draw the classes only
when they pay their cost.

## Smell to candidate pattern

| Smell                                                               | Candidate pattern                                         |
|---------------------------------------------------------------------|-----------------------------------------------------------|
| Behaviour varies at runtime                                         | Strategy or State                                         |
| A tangle of conditionals dispatching on a type or mode              | Strategy or State (Replace Conditional with Polymorphism) |
| Families of related products constructed together                   | Abstract Factory                                          |
| Repeated null guards on an optional collaborator                    | Null Object                                               |
| Adding cross-cutting behaviour around an object without changing it | Decorator                                                 |
| A request that must be queued, logged, or undone                    | Command                                                   |
| Many objects must react when one object changes state               | Observer                                                  |
| A subsystem that is too wide or too complex to use directly         | Facade                                                    |
| An object structure traversed by many unrelated operations          | Visitor                                                   |
| Success-or-failure threaded through return values                   | Result/Either                                             |
| A composable, combinable business rule                              | Specification                                             |

## Ownership and composition

This skill is the source of truth for the generic mechanism: Adapter as wrapping an incompatible interface, Command as
reifying a request, Factory as encapsulating creation, Decorator as adding behaviour without subclassing, Observer as
notifying dependents of state change. That is the level of abstraction this skill owns.

The architecture plugins own the specialised application of these mechanisms:

- **`hexagonal-architecture`** owns boundary adapters. An Adapter in that context is a port implementation; the generic
  pattern is defined here, but the hexagonal meaning and placement rules belong there.
- **`cqrs`** owns the command message. Command as a pattern (reifying a request as an object) is defined here; the CQRS
  command bus, handler wiring, and command-query separation boundary are owned by `cqrs`.
- **`domain-driven-design`** owns the aggregate factory and pairs with Specification. Factory Method and Abstract
  Factory as generic patterns are defined here; the aggregate factory's placement in the domain layer and its
  relationship to the aggregate root are owned by `domain-driven-design`. For Specification, this skill owns the generic
  filter-composition mechanism (a predicate object with `and`, `or`, and `not` combinators); when a specification
  expresses domain eligibility criteria inside an aggregate or bounded context, its placement and naming are owned by
  `domain-driven-design`.
- **`event-sourcing`** pairs with Memento (storing and restoring state snapshots) and Observer (projections reacting to
  events). The generic patterns are defined here; the event-sourcing application belongs in `event-sourcing`.
- **`simplicity-principles`** provides the rule of three (do not generalise before the third case) that governs when to
  reach for a pattern at all.
- **`solid-principles`** provides OCP (the principle that a real variation point warrants a clean extension point) and
  DIP (the principle that high-level logic should not hard-code a low-level dependency), both of which pattern
  application often satisfies.
- **`refactoring`** holds the mechanics that arrive at a pattern: Replace Conditional with Polymorphism, Extract Class,
  Replace Type Code with Subclasses, and similar moves that transform code into a pattern without naming the destination
  in advance.

Repository and dependency injection are out of scope for this skill. Repository belongs to `domain-driven-design` as a
domain concept. Dependency injection belongs to `dependency-injection`.

Cross-references run both ways: when a specialised pattern appears in an architecture plugin, it should reference the
generic pattern definition here.

## Guardrails

- Do not introduce a pattern for its name. A pattern you cannot name a current need for is speculative; it adds
  indirection without a payoff.
- Do not cargo-cult. A pattern from another codebase, or one that worked last time, is not automatically right here.
  Name the problem it solves in this context.
- Do not add gratuitous indirection. Every layer of abstraction has a cost in cognitive load, navigation, and
  maintenance. Earn it.
- Prefer the least machinery that solves the real problem. A function beats a class hierarchy when both solve the
  problem. An in-place conditional beats a full Strategy when there are only two branches and no third is in sight.
- Wait for the rule of three before extracting a generalisation. The third case is the signal; the first two are
  evidence of coincidence.
- Do not let a pattern name obscure the domain language. The ubiquitous language of the domain takes precedence; a
  pattern name is an implementation note, not a business concept.

## Adapt to your context

This skill stays generic on purpose. Layer your own conventions on top:

- Define which patterns your project or team has agreed to standardise on, and document them in your own `CLAUDE.md` or
  a higher-priority skill.
- Record project-specific exceptions: if a context calls for a Singleton that would ordinarily be refused, document the
  reason explicitly.
- This skill does not impose a pattern catalogue on any specific architecture or framework; those conventions live in
  the architecture plugins or project-level configuration files.

## Reference

For canonical definitions, TypeScript minimal-form examples, before-and-after refactoring illustrations, and detailed
when-not-to-apply notes, read the four reference files:

- `references/creational.md`: Factory Method, Abstract Factory, Builder, Prototype, Singleton, and when to prefer plain
  construction over a factory.
- `references/structural.md`: Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy, and how Adapter and
  Decorator differ in intent.
- `references/behavioral.md`: Chain of Responsibility, Command, Interpreter, Iterator, Mediator, Memento, Observer,
  State, Strategy, Template Method, Visitor, and the functional-style alternatives.
- `references/modern-idioms.md`: Null Object, Result/Either, Specification, and other post-GoF patterns with idiomatic
  TypeScript forms.
