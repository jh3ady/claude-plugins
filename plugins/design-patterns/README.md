# design-patterns

A Claude Code plugin that applies judgement to design pattern usage in the code you write and review. Claude already knows what a pattern is; the value this plugin adds is the when: when a pattern is warranted by a real, named variation point; when to refuse one; what the minimal form looks like; and how patterns compose with one another and with the architecture plugins in this collection.

It stays generic on purpose: compose it with your own project conventions and your team or personal rules.

## What it does

When you introduce, review, or refactor around a point of variation; hesitate between two patterns; ask whether a pattern is warranted; or recognise a smell whose named resolution is a design pattern, the bundled skill applies:

- A decision reflex grounded in the rule of three: wait for the third case before generalising, because the first two are evidence of coincidence, not a pattern worth naming.
- The distinction between pragmatism and over-engineering: a real, identified variation point warrants a clean extension point; an anticipated one is speculative abstraction, not a reason to abstract.
- A preference for the minimal form: a function parameter before a class hierarchy, a closure before a Command class, a wrapping function before a Decorator class. Draw the classes only when they carry state across calls, express a contract the type system must enforce, or are implemented by many collaborators.
- A smell-to-candidate mapping for the most common triggers: runtime variation, type-dispatch tangles, families of related products, repeated null guards, cross-cutting behaviour, request reification, observer fans, wide subsystems, success-or-failure threading, and composable business rules.

The skill covers four reference groups:

- **Creational** (Factory Method, Abstract Factory, Builder, Prototype, Singleton): how to encapsulate and delegate object creation, and when plain construction is the right choice.
- **Structural** (Adapter, Bridge, Composite, Decorator, Facade, Flyweight, Proxy): how to compose objects and adapt interfaces, including how Adapter and Decorator differ in intent.
- **Behavioral** (Chain of Responsibility, Command, Interpreter, Iterator, Mediator, Memento, Observer, State, Strategy, Template Method, Visitor): how to distribute responsibility and vary algorithms at runtime, including functional-style alternatives.
- **Modern idioms** (Null Object, Result/Either, Specification, and related functional patterns): post-GoF solutions with idiomatic TypeScript forms.

**Ownership by level.** This skill is the source of truth for the generic mechanism: Adapter as wrapping an incompatible interface, Command as reifying a request, Factory as encapsulating creation, Decorator as adding behaviour without subclassing, Observer as notifying dependents of state change. The architecture plugins own the specialised application of these mechanisms and reference the generic definition here. This split keeps the pattern catalogue stable regardless of which architecture plugins are installed, and lets each architecture plugin explain what a generic mechanism means in its specific context without duplicating the canonical definition.

## Relationship to other plugins

- `solid-principles`: OCP and DIP are the principles behind most behavioral patterns. An extension point opened with Strategy, State, or Decorator is OCP applied correctly: the variation point is real and identified. A dependency on an abstraction rather than a concrete implementation is DIP applied, which pattern application often satisfies.
- `simplicity-principles`: the rule of three (do not generalise before the third case) is the practical gate for reaching for a pattern at all. The duplication-versus-the-wrong-abstraction tension sets the ceiling: sometimes the duplication is cheaper than the cost of the indirection.
- `dependency-injection`: wiring a Strategy or a factory through a dependency injection container is the application layer, not the pattern itself. Singleton as a pattern (one instance enforced by construction) also differs from a singleton lifetime managed by a container, which belongs to `dependency-injection`.
- `hexagonal-architecture`: boundary adapters are the specialised application of the Adapter pattern; port-implementation placement rules belong there, not here.
- `cqrs`: the Command pattern (reifying a request as an object) is a false friend of the CQRS command message. The generic pattern is defined here; the command bus, handler wiring, and command-query separation boundary belong to `cqrs`.
- `domain-driven-design`: the aggregate factory is the specialised application of Factory Method or Abstract Factory; aggregate placement rules belong there. Specification as a composable domain eligibility criterion pairs with this skill's generic filter-composition mechanism (a predicate object with `and`, `or`, and `not` combinators); placement inside a bounded context belongs to `domain-driven-design`.
- `event-sourcing`: Memento (storing and restoring state snapshots) and Observer (projections reacting to events) pair with event sourcing at the store level. The generic patterns are defined here; the event-sourcing application belongs in `event-sourcing`.
- `refactoring`: the mechanics that arrive at a pattern (Replace Conditional with Polymorphism, Extract Class, Replace Type Code with Subclasses) belong to `refactoring`. This skill names the destination pattern; the mechanical route to reach it is owned there.

**Out of scope.** Repository and dependency injection are not covered here. Repository belongs to `domain-driven-design` as a domain concept. Dependency injection belongs to `dependency-injection`.

## Install

```bash
/plugin marketplace add jh3ady/claude-plugins
/plugin install design-patterns@jh3ady-claude-plugins
```

## Adapt to your context

This plugin is a baseline catalogue of judgement heuristics, not a dogma. Layer your own conventions on top: record which patterns your project or team has agreed to standardise on, document project-specific exceptions with an explicit reason (for example, a Singleton that is justified by the runtime environment), and configure framework-specific or architecture-specific rules in your own `CLAUDE.md` or a higher-priority skill. The plugin does not impose them.

## License

Released under the [MIT License](LICENSE).
